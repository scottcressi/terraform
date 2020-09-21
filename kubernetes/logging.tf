resource "kubernetes_namespace" "logging" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "logging"
  }
}

resource "helm_release" "metricbeat" {
  name       = "metricbeat"
  repository = "https://helm.elastic.co"
  chart      = "metricbeat"
  version    = "7.9.1"
  namespace  = "logging"

  depends_on = [kubernetes_namespace.logging]

  values = [<<EOF
daemonset:
  metricbeatConfig:
    metricbeat.yml: |
      metricbeat.modules:
      - module: prometheus
        period: 10s
        metricsets: ["collector"]
        hosts: ["prometheus-operator-prometheus.monitoring:9090"]
        metrics_path: /metrics
      output.logstash:
        hosts: 'logstash-logstash.logging:5044'
deployment:
  metricbeatConfig:
    metricbeat.yml: |
      metricbeat.modules:
      - module: kubernetes
        enabled: true
        metricsets:
          - state_node
          - state_deployment
          - state_replicaset
          - state_pod
          - state_container
        period: 10s
        hosts: ["prometheus-operator-kube-state-metrics.monitoring:8080"]
      output.logstash:
        hosts: 'logstash-logstash.logging:5044'
EOF
  ]

}

resource "helm_release" "opendistro" {
  name      = "opendistro"
  chart     = "/var/tmp/opendistro-build/helm/opendistro-es/"
  namespace = "logging"

  depends_on = [kubernetes_namespace.logging]

}

resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = "7.9.1"
  namespace  = "logging"

  depends_on = [kubernetes_namespace.logging]

  values = [<<EOF
logstashPipeline:
  logstash.conf: |
    input {
            beats {
              port => 5044
            }
    }
    output {
      elasticsearch {
          hosts => ["https://opendistro-opendistro-es-client-service:9200"]
          ssl => true
          ssl_certificate_verification => false
          user => "admin"
          password => "admin"
          ilm_enabled => false
        }
      }
logstashConfig:
  logstash.yml: |
    http.host: "0.0.0.0"
service:
  type: ClusterIP
  ports:
    - name: beats
      port: 5044
      protocol: TCP
      targetPort: 5044
EOF
  ]

}

resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  version    = "7.9.1"
  namespace  = "logging"

  depends_on = [kubernetes_namespace.logging]

  values = [<<EOF
filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
    - type: log
      enabled: true
      paths:
        - /var/log/*.log
        - /var/log/messages
        - /var/log/syslog
    - type: docker
      containers.ids:
      - "*"
      processors:
        - add_kubernetes_metadata:
        - drop_event:
            when:
              equals:
                kubernetes.container.name: "filebeat"
    output.file:
      enabled: false
    output.logstash:
      hosts: ["logstash-logstash:5044"]
EOF
  ]

}

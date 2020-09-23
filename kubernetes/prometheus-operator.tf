resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "monitoring"
  }
}

resource "helm_release" "mariadb" {
  name       = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"
  version    = "7.9.2"
  namespace  = "monitoring"

  depends_on = [kubernetes_namespace.monitoring]

  values = [<<EOF
db:
  user: "grafana"
  password: ${random_password.grafana-password.result}
  name: grafana
EOF
  ]

}

resource "helm_release" "prometheus-operator" {
  name       = "prometheus-operator"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "prometheus-operator"
  version    = "9.3.1"
  namespace  = "monitoring"

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.mariadb,
  ]

  values = [<<EOF
prometheusOperator:
  cleanupCustomResourceBeforeInstall: true
  cleanupCustomResource: false
prometheus:
  prometheusSpec:
    thanos:
      image: thanosio/thanos:v0.14.0
#    storageSpec:
#      volumeClaimTemplate:
#        spec:
#          storageClassName: gp2
#          accessModes: ["ReadWriteOnce"]
#          resources:
#            requests:
#              storage: 50Gi
  ingress:
    hosts:
    - prometheus-k8s.${var.environment}.${var.zone}.com
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: custom-nginx-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'

grafana:
  grafana.ini:
    database:
      type: mysql
      user: grafana
      name: grafana
      host: mariadb.monitoring
      password: ${random_password.grafana-password.result}
    server:
      domain: grafana-k8s.${var.environment}.${var.zone}.com
  persistence:
    enabled: true
  enabled: ${var.environment == "local" ? true : false || var.environment == "shared" ? true : false}
  plugins:
    - grafana-piechart-panel
  ingress:
    hosts:
    - grafana-k8s.${var.environment}.${var.zone}.com
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
  additionalDataSources:
  - name: influxdb-test
    access: proxy
    editable: false
    type: influxdb
    url: http://influxdb:8086
EOF
  ]

}

resource "helm_release" "thanos" {
  name       = "thanos"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "thanos"
  version    = "2.4.1"
  namespace  = "monitoring"

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus-operator,
  ]

  values = [<<EOF
objstoreConfig: |-
  type: s3
  config:
    bucket: thanos
    endpoint: thanos-minio.monitoring:9000
    access_key: minio
    secret_key: minio123
    insecure: true
querier:
  dnsDiscovery:
    sidecarsService: prometheus-operator-prometheus-thanos
    sidecarsNamespace: monitoring
bucketweb:
  enabled: true
compactor:
  enabled: true
storegateway:
  enabled: true
ruler:
  enabled: true
  alertmanagers:
    - http://prometheus-operator-alertmanager.monitoring:9093
  config: |-
    groups:
      - name: "metamonitoring"
        rules:
          - alert: "PrometheusDown"
            expr: absent(up{prometheus="monitoring/prometheus-operator"})
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
minio:
  enabled: true
  accessKey:
    password: "minio"
  secretKey:
    password: "minio123"
  defaultBuckets: "thanos"
EOF
  ]

}

resource "random_password" "grafana-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

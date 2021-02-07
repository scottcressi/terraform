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
  count      = var.environment == "shared" || var.environment == "local" ? 1 : 0
  name       = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"
  version    = "7.10.4"
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

resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "13.5.0"
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

alertmanager:
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: ${data.vault_generic_secret.alertmanager-slack-token.data["slack_token"]}

    route:
      receiver: "null"
      routes:
      - match:
          severity: critical
        receiver: slack-notifications

    receivers:
    - name: "null"
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#alertmanager-${var.environment}'
EOF
  ]

}

resource "helm_release" "thanos" {
  count      = var.environment == "shared" || var.environment == "local" ? 1 : 0
  name       = "thanos"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "thanos"
  version    = "3.8.1"
  namespace  = "monitoring"

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.kube-prometheus,
  ]

  values = [<<EOF

objstoreConfig:
  type: S3
  config:
    access_key: ${data.vault_generic_secret.thanos-access-key.data["thanos_access_key"]}
    secret_key: ${data.vault_generic_secret.thanos-access-key.data["thanos_secret_key"]}
    endpoint: s3.us-east-1.amazonaws.com
    bucket: thanos-374012539393
    insecure: false
    signature_version2: false
    http_config:
      idle_conn_timeout: 10s
      response_header_timeout: 15s
      insecure_skip_verify: false
    sse_config:
      type: "SSE-S3"

querier:
  dnsDiscovery:
    sidecarsService: prometheus-operated
    sidecarsNamespace: monitoring
  ingress:
    enabled: true
    hostname: querier-k8s.${var.environment}.${var.zone}.com
    grpc:
      enabled: true
      hostname: storeapi-k8s.${var.environment}.${var.zone}.com
      annotations:
        nginx.ingress.kubernetes.io/backend-protocol: GRPC
  rbac:
    create: true
  pspEnabled: true
  pdb:
    create: true
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPU: 60
    targetMemory: 60

bucketweb:
  enabled: true

#compactor:
#  enabled: true
#  retentionResolutionRaw: 1y
#  retentionResolution5m: 1y
#  retentionResolution1h: 2y

#storegateway:
#  enabled: true
#  pdb:
#    create: true
#  autoscaling:
#    enabled: true
#    minReplicas: 1
#    maxReplicas: 5
#    targetCPU: 60
#    targetMemory: 60

#ruler:
#  enabled: true
#  alertmanagers:
#    - http://prometheus-operator-alertmanager.monitoring:9093
#  config: |-
#    groups:
#      - name: "metamonitoring"
#        rules:
#          - alert: "PrometheusDown"
#            expr: absent(up{prometheus="monitoring/prometheus-operator"})

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    labels:
      release: kube-prometheus-stack
    interval: 30s
    scrapeTimeout: 30s

volumePermissions:
  enabled: true

EOF
  ]

}

resource "random_password" "grafana-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "vault_generic_secret" "alertmanager-slack-token" {
  path = "secret/helm/prometheus"
}

data "vault_generic_secret" "thanos-access-key" {
  path = "secret/helm/prometheus"
}

data "vault_generic_secret" "thanos-secret-key" {
  path = "secret/helm/prometheus"
}

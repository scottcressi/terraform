resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "3.1.8"
  namespace  = "jenkins"

  depends_on = [kubernetes_namespace.jenkins]

  values = [<<EOF
rbac:
  create: true
controller:
  JenkinsUrl: http://jenkins-k8s.${var.environment}.${var.zone}.com
  HostName: jenkins-k8s.${var.environment}.${var.zone}.com
  adminPassword: foo
  authorizationStrategy: |-
    <authorizationStrategy class="hudson.security.ProjectMatrixAuthorizationStrategy">
      <permission>hudson.model.Hudson.Administer:admin</permission>
    </authorizationStrategy>
  tag: "2.263.4"
  csrf:
    defaultCrumbIssuer:
      enabled: true
  serviceType: ClusterIP
  ingress:
    hostName: jenkins-k8s.${var.environment}.${var.zone}.com
    enabled: false
    ApiVersion: extensions/v1beta1
    annotations:
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: "0.0.0.0"
  installPlugins:
  - ansicolor
  - configuration-as-code
  - credentials-binding
  - git
  - github
  - job-dsl
  - kubernetes
  - matrix-auth
  - pipeline-aws
  - prometheus
  - slack
  - workflow-aggregator
  - workflow-job
  overwriteJobs: true
  overwriteConfig: true
  numExecutors: 1
EOF
  ]

}

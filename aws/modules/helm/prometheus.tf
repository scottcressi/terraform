terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "prometheus"
  }
}

resource "kubectl_manifest" "test" {
    yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: default
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: prometheus
  project: default
  source:
    chart: prometheus
    helm:
      values: |
        pushgateway:
          enabled: false
    repoURL: https://prometheus-community.github.io/helm-charts
    targetRevision: 13.0.2
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML
}

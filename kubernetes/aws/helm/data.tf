data "vault_generic_secret" "kubewatch-slack-token" {
  path = "secret/helm/kubewatch"
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

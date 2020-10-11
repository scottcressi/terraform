#!/usr/local/env bash

init(){
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
vault server -config=config-vault.hcl -dev -dev-root-token-id="root" & disown
sleep 1
vault status
vault audit enable file file_path=audit.log
vault secrets enable transit
vault write -f transit/keys/autounseal
vault policy write autounseal autounseal.hcl
vault token create -policy="autounseal" -wrap-ttl=120 > temp-unseal
WRAPPING_TOKEN="$(grep wrapping_token: temp-unseal | awk '{print $2}')"
vault unwrap "$WRAPPING_TOKEN" > temp-wrap
}

transit(){
export VAULT_TOKEN="$(grep 'token ' temp-wrap | awk '{print $2}')"
vault server -config=config-transit.hcl & disown
sleep 1
vault operator init -address=http://127.0.0.1:8100 -recovery-shares=1 -recovery-threshold=1 > recovery-key.txt
}

secrets(){
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
vault kv put secret/helm/kubewatch slack_token=foo ; sleep .5
vault kv put secret/helm/prometheus slack_token=foo ; sleep .5

echo """
set the following in your /etc/hosts:
127.0.0.1 vault-k8s.ENV.ZONE.com
"""
}

complete(){
init
transit
secrets
}

"$@"

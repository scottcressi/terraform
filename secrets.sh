#!/usr/local/env bash

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

if ! pgrep vault > /dev/null ; then
    vault server -dev -dev-root-token-id="$VAULT_TOKEN" & disown
    echo waiting for initialization
    sleep 1
fi

vault kv put secret/helm/kubewatch slack_token=foo ; sleep .5
vault kv put secret/helm/prometheus slack_token=foo ; sleep .5

echo """
set the following in your /etc/hosts:
127.0.0.1 vault-k8s.ENV.ZONE.com
"""

if ! command -v docker ; then echo docker not installed ;  exit 0 ; fi
if ! command -v vault ; then echo vault not installed ;  exit 0 ; fi

if ! pgrep vault > /dev/null ; then
    vault server -dev -dev-root-token-id="root" & disown
    echo waiting for initialization
    sleep 1
fi

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

vault kv put secret/helm/kubewatch slack_token=foo ; sleep .5

echo """
set the following in your /etc/hosts:
127.0.0.1 vault-k8s.ENV.ZONE.com
"""

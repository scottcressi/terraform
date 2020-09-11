if ! command -v docker ; then echo docker not installed ;  exit 0 ; fi
if ! command -v vault ; then echo vault not installed ;  exit 0 ; fi
if ! pgrep vault > /dev/null ; then vault server -dev -dev-root-token-id="root" & disown ; fi

echo waiting for initialization
sleep 1

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

vault kv put secret/helm/kubewatch slack_token=foo
vault kv put secret/helm/prometheus-operator db_password=foo
vault kv put secret/helm/external-dns secret_key=foo
vault kv put secret/helm/docker-registry haSharedSecret=foo

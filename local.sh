#!/usr/bin/env bash

if ! command -v terraform ; then echo terraform not installed ;  exit 0 ; fi
if ! command -v vault ; then echo vault not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker not installed ;  exit 0 ; fi
if ! command -v docker-compose ; then echo docker-compose not installed ;  exit 0 ; fi

POSTGRES_ADDRESS=localhost
POSTGRES_USER=terraform

echo
echo enter postgres password to set:
read -r POSTGRES_PASSWORD

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

init_vault(){
    export VAULT_ADDR=http://localhost:8200
    export VAULT_TOKEN=root

    if ! pgrep vault > /dev/null ; then
    vault server -dev -dev-root-token-id="$VAULT_TOKEN" &
    echo waiting for initialization
    sleep 1
    fi

    vault kv put secret/helm/kubewatch slack_token=foo ; sleep .5
    vault kv put secret/helm/prometheus slack_token=foo ; sleep .5

    echo """
    set the following in your /etc/hosts:
    127.0.0.1 vault-k8s.ENV.ZONE.com
    """
}

create_backend(){
    export POSTGRES_PASSWORD=$POSTGRES_PASSWORD
    docker-compose up -d
}

download_charts(){
    # open distro
    git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git /var/tmp/opendistro-build
    cd /var/tmp/opendistro-build/helm/opendistro-es || exit
    git pull
    git checkout v1.11.0
    helm package .

    # docker-registry-ui
    git clone https://github.com/Joxit/docker-registry-ui.git /var/tmp/docker-registry-ui
    cd /var/tmp/docker-registry-ui || exit
    git pull
    git checkout 1.5.0
}

init_terraform(){
    cd "$DIR"/kubernetes || exit
    terraform init -backend-config="conn_str=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_ADDRESS/terraform_backend?sslmode=disable" || echo "Done !"
    terraform workspace new default || if [ $? -eq 0 ]; then echo "Done !"; else echo "Workspace \"default\" was not created"; fi
    terraform init
}

echo
echo "##### vault"
echo
init_vault
echo
echo "##### backend"
echo
create_backend
echo
echo "##### charts"
echo
download_charts
echo
echo "##### init"
echo
init_terraform

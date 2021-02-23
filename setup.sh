#!/usr/bin/env sh

if ! command -v terraform > /dev/null ; then echo terraform not installed ;  exit 0 ; fi
if ! command -v docker > /dev/null ; then echo docker not installed ;  exit 0 ; fi
if ! command -v docker-compose > /dev/null ; then echo docker-compose not installed ;  exit 0 ; fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -eq 0 ] ; then
    echo """
    options:

    setup_vault
    setup_postgres
    setup_prereqs
    setup_charts
    setup_statebucket
    """
    exit 0
fi

setup_statebucket(){
    UUID=$(cat /proc/sys/kernel/random/uuid)
    aws s3 mb s3://terraform-state-"$UUID"
}

setup_vault(){
    # create secrets
    docker-compose up -d vault
    sleep 2
    docker exec -ti terraform_vault_1 sh -c "export VAULT_TOKEN=root \
    ; vault kv put -address http://127.0.0.1:8200 secret/helm/kubewatch slack_token=foo \
    ; vault kv put -address http://127.0.0.1:8200 secret/helm/prometheus slack_token=foo \
    "
    echo """
    set the following in your /etc/hosts:
    127.0.0.1 vault-k8s.ENV.ZONE.com

    run: export VAULT_TOKEN=root
    """
}

setup_postgres(){
    # create vault and postgres backends
    POSTGRES_ADDRESS=localhost
    POSTGRES_USER=terraform
    POSTGRES_PASSWORD=terraform
    export POSTGRES_PASSWORD=$POSTGRES_PASSWORD
    docker-compose up -d postgres

    # terraform init backend
    cd "$DIR"/kubernetes || exit
    terraform init -backend-config="conn_str=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_ADDRESS/terraform_backend?sslmode=disable" || echo "Done !"
    terraform workspace new default || if [ $? -eq 0 ]; then echo "Done !"; else echo "Workspace \"default\" was not created"; fi
    terraform init
}

setup_prereqs(){
    pip install -r requirements.txt
}

setup_charts(){
    git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git /var/tmp/opendistro
    cd /var/tmp/opendistro/helm/opendistro-es || exit
    git pull
    git checkout v1.12.0
    helm package .

    git clone https://github.com/Joxit/docker-registry-ui.git /var/tmp/docker-registry-ui
    cd /var/tmp/docker-registry-ui || exit
    git pull
    git checkout 1.5.2
}

"$@"

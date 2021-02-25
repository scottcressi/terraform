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
    execute_terraform   ex. bash setup.sh execute_terraform dev somehostedzone
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
    git checkout v1.13.0
    helm package .

    git clone https://github.com/Joxit/docker-registry-ui.git /var/tmp/docker-registry-ui
    cd /var/tmp/docker-registry-ui || exit
    git pull
    git checkout 1.5.4
}

execute_terraform(){
    if [ -z "$1" ] ; then echo environment required ; exit 1 ; fi
    if [ -z "$2" ] ; then echo zone required ; exit 1 ; fi
    ENV="$1"
    ZONE="$2"
    echo env: "$ENV"
    echo zone: "$ZONE"
    echo

    vault=vault-k8s."$ENV"."$ZONE".com
    status=$(nc -z "$vault" 8200 ; echo $?)
    if [ "$status" != "0" ] ; then
        echo "$vault" cannot be found
        exit 1
    fi

    array=( $(find aws/environments/"$ENV" -maxdepth 2 -mindepth 2 -type d | grep global) )
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform fmt
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform init
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform validate
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform plan
        cd "$DIR" || exit
    done

    array=( $(find aws/environments/"$ENV" -maxdepth 2 -mindepth 2 -type d | grep -v global) )
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform fmt
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform init
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform validate
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform plan
        cd "$DIR" || exit
    done
}

"$@"

#!/usr/bin/env sh

if ! command -v terraform > /dev/null ; then echo terraform not installed ;  exit 0 ; fi
if ! command -v docker > /dev/null ; then echo docker not installed ;  exit 0 ; fi
if ! command -v docker-compose > /dev/null ; then echo docker-compose not installed ;  exit 0 ; fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -eq 0 ] ; then
    echo """
    options:

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

    loop(){
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform fmt
        cd "$DIR" || exit
    done
    for i in "${array[@]}" ; do
        cd "$i" || exit
        terraform init -upgrade
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

    array=( $(find aws/environments/"$ENV" -maxdepth 2 -mindepth 2 -type d | grep global) )
    loop
    array=( $(find aws/environments/"$ENV" -maxdepth 2 -mindepth 2 -type d | grep -v global) )
    loop
}

"$@"

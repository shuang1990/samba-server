#!/bin/bash

set -e

prj_path=$(cd $(dirname $0); pwd -P)
SCRIPTFILE=`basename $0`

devops_prj_path="$prj_path/devops"

samba_image=dperson/samba
samba_container=samba-server
app=samba
user=docker
passwd=123qwe

base_do_init=0
source $devops_prj_path/base.sh

function run() {
    local data_path="/opt/data/$app"
    ensure_dir "$data_path"
    ensure_permissions "$data_path"

    args="$args -p 139:139 -p 445:445 -p 137:137 -p 138:138"
    args="$args -v $data_path:/share"
    
    local cmd="-u \"$user;$passwd\" -s \"public;/share;yes;no;yes\""
    run_cmd "docker run -d $args  --name $samba_container $samba_image $cmd"
}

function stop() {
    stop_container $samba_container
}

function restart() {
    stop
    run
}

function help() {
	cat <<-EOF
    
    Usage: mamanger.sh [options]
            
        Valid options are:

            run
            stop
            restart
            
            help                      show this help message and exit

EOF
}
ALL_COMMANDS="run stop restart"
list_contains ALL_COMMANDS "$action" || action=help
$action "$@"

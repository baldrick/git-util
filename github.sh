#!/bin/bash

# Manipulate GitHub repos via the REST API

function usage() {
     cat << END_USAGE
     Usage: $0 -u <username> -p <token> -c <clone|get|repos.list|read.grant> -t <target> -r <repo(s)>
         -u: ${github_username}
         -p: ${github_token}
         -c: ${cmd} chosen from available commands:
            clone to clone all repos to the local machine
            get to run HTTP GET on the <target> URL
            repos.list to list all repos for this user
            read.grant to grant read access for the specified repo (* for all) to the target user
         -t: ${target} target for grant access or target resource when 'get'ing
         -r: ${repo} to grant access to
END_USAGE
    exit -1
}

function init() {
    github_api_url=https://api.github.com
    process_arguments "$@"
    exit_if_invalid_arguments
    accept_header="Accept: application/vnd.github.v3+json"
    curl_cmd="curl -u ${github_username}:${github_token} --silent --show-error --include "
}

function process_arguments() {
    repo='*'
    while getopts "u:p:c:t:r:" arg; do
        case $arg in
            u) github_username="$OPTARG";;
            p) github_token="$OPTARG";;
            c) cmd="$OPTARG";;
            t) target="$OPTARG";;
            r) repo="$OPTARG";;
            *) usage;;
        esac
    done
}

function exit_if_invalid_arguments() {
    if [[ -z ${github_username} ]] || [[ -z ${github_token} ]] || [[ -z ${cmd} ]]
    then
        usage
    fi

    case ${cmd} in
        read.grant)
            if [[ -z ${target} ]]
            then
                usage
            fi
            ;;
        *) ;;
    esac
}

function get() {
    local l_resource="$1"
    ${curl_cmd} -H "${accept_header}"       \
        "${github_api_url}/${l_resource}"   \
        --compressed
}

function put() {
    local l_endpoint="$1"
    local l_data="$2"
    ${curl_cmd} -H "${accept_header}"       \
        "${github_api_url}/${l_endpoint}"   \
        --compressed                        \
        --request PUT                       \
        --data-binary "${l_data}"           \
        > /dev/null
}

function find_link_identifier() {
    local l_target=$1
    local l_link_header="$2"
    local l_link_identifier_field=3
    local l_finished=
    while [ -z "${l_finished}" ]
    do
        local l_link_identifier=$(echo ${l_link_header} | cut -d ' ' -f ${l_link_identifier_field} | tr -d ',' | tr -d '\015')
        #echo "Checking link identifier for ${l_target} - ${l_link_identifier}." >&2
        if [ -z "${l_link_identifier}" ]
        then
            echo ""
            l_finished="done"
        elif [ ${l_link_identifier} == "rel=\"${l_target}\"" ]
        then
            echo ${l_link_identifier_field}
            l_finished="done"
        else
            (( l_link_identifier_field += 2 ))
        fi
    done
}

function get_link_from_header() {
    local l_link_type="$1"
    local l_response_file="$2"
    local l_link_header=$(grep ^Link ${l_response_file})
    if [ -z "${l_link_header}" ]
    then
        echo "No Link header" >&2
        echo ""
    else
        local l_link_identifier_field=$(find_link_identifier ${l_link_type} "${l_link_header}")
        if [ -z ${l_link_identifier_field} ]
        then
            echo "No ${l_link_type} link type in link header - ${l_link_header}" >&2
            echo ""
        else
            local l_link_field
            (( l_link_field = l_link_identifier_field - 1 ))
            local l_fullLink=$(echo ${l_link_header} | cut -d ' ' -f ${l_link_field} | tr -d '\<' | tr -d '\>' | tr -d ';')
            echo ${l_fullLink#$github_api_url/}
        fi
    fi
}

function repo_list() {
    local l_response_file=/tmp/$$.l_response
    local l_repositories=/tmp/$$.l_repositories
    [ -f ${l_response_file} ] && rm ${l_response_file}
    [ -f ${l_repositories} ] && rm ${l_repositories}

    local l_next="user/repos"
    local l_last=
    while [ ! -z ${l_next} ]
    do
        echo "Getting $l_next" >&2
        get "${l_next}" >$l_response_file
        local l_body=$(grep -v ^[A-Z] ${l_response_file} | tr -d "\015" | grep -v ^$)
        echo $l_body \
            | jq --compact-output ".[] | if .owner.login == \"${github_username}\" then {name: .full_name, ssh_url: .ssh_url} else null end" \
            | grep -v ^null \
            >> ${l_repositories}

        if [ -z "${l_last}" ]
        then
            l_last=$(get_link_from_header last ${l_response_file})
        fi

        if [ ${l_next} == ${l_last} ]
        then
            echo "All pages retrieved" >&2
            l_next=""
        else
            l_next=$(get_link_from_header next ${l_response_file})
        fi
    done

    cat ${l_repositories}

    [ -f ${l_response_file} ] && rm ${l_response_file}
    [ -f ${l_repositories} ] && rm ${l_repositories}
}

function read_grant_single_repo() {
    local l_target_account="$1"
    local l_repository="$2"

    echo "Granting pull access on ${l_repository} to ${l_target_account}"
    put repos/${l_repository}/collaborators/${l_target_account} '{"permission":"pull"}'
}

function read_grant() {
    local l_target_account="$1"
    local l_repository="$2"
    
    if [[ ${l_repository} == '*' ]]
    then
        local l_repos=$(repo_list)
        local l_repo_json
        for l_repo_json in $l_repos
        do
            local l_repo=$(echo ${l_repo_json} | jq ".name" | tr -d '"')
            read_grant_single_repo "${l_target_account}" "${l_repo}"
        done
    else
        read_grant_single_repo "${l_target_account}" "${l_repository}"
    fi
}

function clone() {
    local l_repos=$(repo_list)
    for l_repo_json in $l_repos
    do
        local l_git_url=$(echo ${l_repo_json} | jq ".ssh_url" | tr -d '"' | sed 's/github.com/baldrickatdb.github/')
        git clone --bare $l_git_url
    done
}

function execute() {
    case "$cmd" in
        "repos.list")
            repo_list
            ;;
        "read.grant")
            read_grant "${target}" "${repo}"
            ;;
        "clone")
            clone
            ;;
        "get")
            get "${target}"
            ;;
        *)
            usage
            ;;
    esac
}

init "$@"
execute

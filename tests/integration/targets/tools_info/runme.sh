#!/usr/bin/env bash

set -eux

function cleanup() {
    ansible-playbook teardown.yml "$@"
    exit 1
}

ANSIBLE_ROLES_PATH="../"
export ANSIBLE_ROLES_PATH

trap 'cleanup "${@}"'  ERR

# Configure test environment
ansible-playbook setup.yml "$@"

# Run tests
ansible-playbook test.yml -i inventory.yml "$@"

# cleanup environment
ansible-playbook teardown.yml "$@"
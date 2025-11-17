#!/usr/bin/env bash

set -eux

function cleanup() {
    # rm -f ./inventory.yml
    exit 1
}

ANSIBLE_ROLES_PATH="../"
export ANSIBLE_ROLES_PATH

trap 'cleanup "${@}"'  ERR

# Configure test environment
ansible-playbook setup.yml -e "ansible_mcp_inventory_file_path=./inventory.yml" "$@"

# Run tests
ansible-playbook test.yml -i inventory.yml "$@"

# Remove inventory file
rm -f ./inventory.yml
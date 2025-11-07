#!/usr/bin/env bash
set -eux
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks
export ANSIBLE_ROLES_PATH=../

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="${SCRIPT_DIR}/mcpservers.json"
INVENTORY="${SCRIPT_DIR}/inventory.yml"

# Cleanup function to remove generated inventory file
cleanup() {
    local exit_code=$?
    rm -f "${INVENTORY}"
    exit "${exit_code}"
}

# Set up trap early to ensure cleanup runs on error/early exit
trap cleanup EXIT

GITHUB_PAT_VALUE="${github_mcp_pat:-${ANSIBLE_TEST_GITHUB_PAT:-${GITHUB_PAT:-${GITHUB_TOKEN:-${GITHUB_PERSONAL_ACCESS_TOKEN:-}}}}}"

# Generate inventory file with PAT injected from template
# This will overwrite the existing inventory.yml file with the generated version
if [ -n "${GITHUB_PAT_VALUE:-}" ]; then
    ansible-playbook -c local generate_inventory.yml -e "github_mcp_pat=${GITHUB_PAT_VALUE}" "$@"
else
    ansible-playbook -c local generate_inventory.yml "$@"
fi

# Run integration tests
ansible-playbook -i "${INVENTORY}" tasks/main.yml -e "ansible_mcp_manifest_path=${MANIFEST_PATH}" "$@"

# Delete generated inventory file after tests complete
rm -f "${INVENTORY}"

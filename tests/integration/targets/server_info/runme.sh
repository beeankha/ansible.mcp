#!/usr/bin/env bash
set -eux
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTEGRATION_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# Use shared mcpservers.json from integration directory (can be overridden per-target if needed)
MANIFEST_PATH="${INTEGRATION_DIR}/mcpservers.json"
INVENTORY="${SCRIPT_DIR}/inventory.yml"
# Try to use the role's playbook first (for local testing), fall back to target's playbook (for ansible-test)
ROLE_PLAYBOOK="${INTEGRATION_DIR}/roles/setup/setup_inventory.yml"
TARGET_PLAYBOOK="${SCRIPT_DIR}/setup_tasks.yml"
if [ -f "${ROLE_PLAYBOOK}" ]; then
    SETUP_PLAYBOOK="${ROLE_PLAYBOOK}"
    export ANSIBLE_ROLES_PATH="${INTEGRATION_DIR}/roles"
else
    # Fallback for ansible-test (roles/ directory not copied)
    SETUP_PLAYBOOK="${TARGET_PLAYBOOK}"
fi

# Cleanup function to remove generated inventory file
cleanup() {
    local exit_code=$?
    rm -f "${INVENTORY}"
    exit "${exit_code}"
}

# Set up trap early to ensure cleanup runs on error/early exit
trap cleanup EXIT

# Get GitHub PAT from environment variables (github_mcp_pat should be set by zuul/ansible-test)
GITHUB_PAT_VALUE="${github_mcp_pat:-${ANSIBLE_TEST_GITHUB_PAT:-${GITHUB_PAT:-${GITHUB_TOKEN:-${GITHUB_PERSONAL_ACCESS_TOKEN:-}}}}}"

# Generate inventory file using setup playbook
# Always pass github_mcp_pat (even if empty) so template can check if it's defined
ansible-playbook -c local "${SETUP_PLAYBOOK}" \
    -e "github_mcp_pat=${GITHUB_PAT_VALUE:-}" \
    -e "ansible_mcp_manifest_path=${MANIFEST_PATH}" \
    -e "ansible_mcp_inventory_file=${INVENTORY}" \
    -e "ansible_mcp_inventory_dir=${SCRIPT_DIR}" \
    "$@"

# Run integration tests
ansible-playbook -i "${INVENTORY}" "${SCRIPT_DIR}/tasks/main.yml" -e "ansible_mcp_manifest_path=${MANIFEST_PATH}" "$@"

# Delete generated inventory file after tests complete
rm -f "${INVENTORY}"

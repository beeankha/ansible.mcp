#!/usr/bin/env bash
set -eux
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks
export ANSIBLE_ROLES_PATH=../

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GITHUB_PAT_VALUE="${ANSIBLE_TEST_GITHUB_PAT:-${GITHUB_PAT:-${GITHUB_TOKEN:-${GITHUB_PERSONAL_ACCESS_TOKEN:-}}}}"

EXTRA_VARS=""
if [ -n "${GITHUB_PAT_VALUE:-}" ]; then
    EXTRA_VARS="-e github_pat='${GITHUB_PAT_VALUE}'"
fi

INVENTORY="${SCRIPT_DIR}/inventory.yml"

ansible-playbook -i "${INVENTORY}" tasks/main.yml ${EXTRA_VARS} "$@"

#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: installs this repo's
# dependencies and tools so builds, linters and tests work from the first
# prompt. The container is snapshotted after the hook finishes, so later
# sessions reuse what it installed.
#
# Local sessions are left alone: developers manage their own installs.
set -euo pipefail

cat >/dev/null || true

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Same Terraform version as the fmt and validate workflows.
TF_VERSION=1.15.0

if [ "$(terraform version -json 2>/dev/null | jq -r .terraform_version)" != "$TF_VERSION" ]; then
  curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip
  unzip -o -q /tmp/terraform.zip terraform -d /usr/local/bin
fi
# Downloads providers so `terraform validate` works without credentials.
terraform init -backend=false -input=false >/dev/null

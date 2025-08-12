#!/usr/bin/env bash
set -euo pipefail

az login >/dev/null

terraform -chdir=infra/terraform destroy "$@"

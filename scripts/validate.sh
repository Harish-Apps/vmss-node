#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=infra/terraform fmt -check
terraform -chdir=infra/terraform validate

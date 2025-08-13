#!/usr/bin/env bash
set -euo pipefail
pushd terraform
terraform destroy -auto-approve
popd

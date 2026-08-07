#!/bin/bash
set -e

cd terraform

terraform init -input=false

terraform plan -out=tfplan.binary -input=false

terraform show -json tfplan.binary > tfplan.json

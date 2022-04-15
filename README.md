# Infrastructure-live
## Component description
- live (config ENV for stages)
- modules (modules for use)

## Pre-requisites
1. Terraform version `1.1.4` or newer.
2. Terragrunt version `v0.36.0` or newer.
3. Make your GCP Service accounts get credentials (Assign Role `Owner or Editor`)
4. Make `KEYS` then Download `credentials.json` and place into folder `live` >> `{stage}` (e.g. DIR live/staging/)
5. Fill in your into `live` >> `{stage}` >> `{module}` >> `terragrunt.hcl` as you wish

## Deploying a single module
1. `cd` into the module's folder (e.g. cd live/staging/gcp-gke)
2. Run `terragrunt plan` to see the changes you're about to apply
3. If the plan looks good, run `terragrunt apply`

## Deploying all modules in a region
1. cd into the stage folder (e.g. cd live/staging)
2. Run `terragrunt plan-all` to see all the changes you're about to apply
3. If the plan looks good, run `terragrunt apply-all`
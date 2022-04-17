# Infrastructure-live
## Component description
- live (config ENV for stages)
- modules (modules for use)

## Pre-requisites
1. Terraform version `1.1.4` or newer.
2. Terragrunt version `v0.36.0` or newer.
3. Make your GCP Service accounts get credentials (Assign Role `Owner or Editor`)
4. Make `KEYS` then Download `credentials.json` and place into folder `live` >> `{stage}` (e.g. DIR live/staging/credentials.json)
5. Fill in your into `live` >> `{stage}` >> `{module}` >> `terragrunt.hcl` as you wish

## Deploying a single module (We use this)
1. `cd` into the module's folder (e.g. cd live/staging/gcp-gke)
2. Run `terragrunt plan` to see the changes you're about to apply
3. If the plan looks good, run `terragrunt apply`

## Create ServiceAccount(SA) to access into Cluster GCP
1. Create SA
```bash
gcloud iam service-accounts create {NAME_OF_SA}
```
2. Binding policy to the SA
```bash
gcloud projects add-iam-policy-binding {PROJECT_ID} \
    --member=serviceAccount:{NAME_OF_SA}@{PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/container.developer
```
3. Create `KEY` to the SA
```bash
gcloud iam service-accounts keys create gsa-key.json \
    --iam-account={NAME_OF_SA}@{PROJECT_ID}.iam.gserviceaccount.com
```
4. Get `endpoint` for fill in `kubeconfig.yaml`
```bash
gcloud container clusters describe {CLUSTER_NAME} \
    --zone=asia-southeast1-b \
    --format="value(endpoint)"
```
5. Get `masterAuth.clusterCaCertificate)` for fill in `kubeconfig.yaml`
```bash
gcloud container clusters describe {CLUSTER_NAME} \
    --zone=asia-southeast1-b \
    --format="value(masterAuth.clusterCaCertificate)"
```
6. Create `kubeconfig.yaml` then Fill in
> Temp. kubeconfig.yaml
```yaml
apiVersion: v1
kind: Config
clusters:
- name: {CLUSTER_NAME}
  cluster:
    server: https://{endpoint}
    certificate-authority-data: masterAuth.clusterCaCertificate
users:
- name: {NAME_OF_SA}
  user:
    auth-provider:
      name: gcp
contexts:
- context:
    cluster: {CLUSTER_NAME}
    user: {NAME_OF_SA}
  name: {CLUSTER_NAME}-ci-cd
current-context: {CLUSTER_NAME}-ci-cd
```
7. Pre-Use and Enjoy access into cluster
```bash
export KUBECONFIG=~/PATH-OF-KUBECONFIG/kubeconfig.yaml
export GOOGLE_APPLICATION_CREDENTIALS=/PATH-OF-GSA-KEY/gsa-key.json
```
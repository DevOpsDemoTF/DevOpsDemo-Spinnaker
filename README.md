# Spinnaker deployment to AKS Kubernetes cluster #
This Terraform module creates a Spinnaker deployment and pre-configures pipeline templates
for use as a deployment environment for my [DevOpsDemo](https://github.com/DevOpsDemoTF/DevOpsDemo)

### Requirements ###
* Terraform v0.12+
* Azure CLI
* kubectl
* helm

### Features ###
* Support for multiple environments/stages
* Multi-stage deployment pipeline e.g. DEV -> STAGE -> PROD
* Promotion of Docker images between registries
* Optional manual validation stage before promotion
* Pre-configured Spinnaker pipeline templates

### Links ###
* https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal
* https://www.spinnaker.io/setup/spin/#install-and-configure-spin-cli

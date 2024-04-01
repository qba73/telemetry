SHELL                   = /bin/bash
ROOT_DIR                = $(shell git rev-parse --show-toplevel)
NODE_IP                 =
KUBE_CONFIG_FOLDER      = ${HOME}/.kube
KIND_KUBE_CONFIG_FOLDER = $(KUBE_CONFIG_FOLDER)/kind
IP_FAMILY               = dual
TAG                     ?= edge ## The tag of the image. For example, edge
K8S_CLUSTER_NAME        ?= local ## The name used when creating/using a Kind Kubernetes cluster
K8S_TIMEOUT             ?= 75s ## The timeout used when creating a Kind Kubernetes cluster

.PHONY: help ## Show this help
help: ## Show available make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "; printf "Usage:\n\n    make \033[36m<target>\033[0m [VARIABLE=value...]\n\nTargets:\n\n"}; {printf "    \033[36m%-30s\033[0m %s\n", $$1, $$2}'

$(KUBE_CONFIG_FOLDER):
	@mkdir -p $@

$(KIND_KUBE_CONFIG_FOLDER): $(KUBE_CONFIG_FOLDER)
	@mkdir -p $@

.PHONY: create-cluster ## Create Kind K8s Cluster
create-cluster: $(KIND_KUBE_CONFIG_FOLDER) ## Create a Kind K8S cluster
	@kind create cluster \
		--name $(K8S_CLUSTER_NAME) \
		--image=kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245 \
		--config=<(sed 's/dual/${IP_FAMILY}/' $(ROOT_DIR)/k8s/kind.yaml) \
		--wait $(K8S_TIMEOUT)
	@kind get kubeconfig --name $(K8S_CLUSTER_NAME) --internal > $(KIND_KUBE_CONFIG_FOLDER)/config

.PHONY: delete-cluster
delete-cluster: ## Delete Kind K8s Cluster
	@kind delete cluster --name $(K8S_CLUSTER_NAME)
	@rm -f $(KIND_KUBE_CONFIG_FOLDER)/config

.PHONY: image-load
image-load: ## Load the image into the Kind K8S cluster
	@kind load docker-image $(BUILD_IMAGE) --name $(K8S_CLUSTER_NAME)

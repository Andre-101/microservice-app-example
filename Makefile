KIND_CLUSTER_NAME = microapp
KIND_CONFIG = infra/kind/kind-config.yaml
NAMESPACE = microapp

.PHONY: kind-up
kind-up:
	kind create cluster --name $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG)
	kubectl config set-context --current --namespace=$(NAMESPACE)

.PHONY: kind-down
kind-down:
	kind delete cluster --name $(KIND_CLUSTER_NAME) || true

.PHONY: kctx
kctx:
	kubectl cluster-info --context kind-$(KIND_CLUSTER_NAME)

.PHONY: deploy-base
deploy-base:
	kubectl apply -f infra/k8s/base/namespace.yaml

.PHONY: deploy-app
deploy-app:
	kubectl apply -f infra/k8s/app/
	kubectl apply -f infra/k8s/app/hpa/

.PHONY: deploy
deploy: deploy-base deploy-app

# Instala Nginx Ingress en kind usando Helm (controller estándar)
.PHONY: ingress-up
ingress-up:
	sudo chmod 755 /usr/local/bin/helm
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

.PHONY: deploy-monitoring
deploy-monitoring:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
		-n monitoring --create-namespace \
		-f infra/k8s/monitoring/values.yaml

# AHORA el frontend se accede SIEMPRE a través del Ingress
.PHONY: port-forward-frontend
port-forward-frontend:
	kubectl port-forward svc/ingress-nginx-controller 8080:80 -n ingress-nginx

.PHONY: port-forward-grafana
port-forward-grafana:
	kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring

.PHONY: load-images-kind
load-images-kind:
	kind load docker-image ghcr.io/andre-101/microapp-auth-api:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image ghcr.io/andre-101/microapp-todos-api:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image ghcr.io/andre-101/microapp-users-api:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image ghcr.io/andre-101/microapp-frontend:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image ghcr.io/andre-101/microapp-log-message-processor:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image redis:7-alpine --name $(KIND_CLUSTER_NAME)

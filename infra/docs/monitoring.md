# Monitoring — Prometheus & Grafana

## 1. Desplegar el stack de monitoreo

Desde la raíz del repo:

```bash
make deploy-monitoring
Esto instala kube-prometheus-stack en el namespace monitoring usando infra/k8s/monitoring/values.yaml.

Verifica:

bash
Copiar código
kubectl get pods -n monitoring
kubectl get svc -n monitoring
2. Acceder a Grafana
Haz port-forward:

bash
Copiar código
make port-forward-grafana
Abre en tu navegador: http://localhost:3000.

Credenciales por defecto (según values.yaml):

Usuario: admin

Password: admin

3. Dashboards útiles
En Grafana, revisa:

Dashboard de Kubernetes / Compute Resources / Namespace para ver CPU/memoria por namespace.

Dashboard de Kubernetes / Compute Resources / Pod para revisar los pods de microapp.

Observa el comportamiento de todos-api cuando ejecutes la prueba de HPA.

4. Métricas clave a mostrar en la presentación
Uso de CPU de los pods de todos-api (antes, durante y después de la prueba de carga).

Número de réplicas de todos-api (combinado con el HPA).

Estado general del clúster (nodos y namespace microapp).
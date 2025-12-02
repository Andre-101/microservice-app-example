# Microservice App - PRFT Devops Training

This is the application you are going to use through the whole traninig. This, hopefully, will teach you the fundamentals you need in a real project. You will find a basic TODO application designed with a [microservice architecture](https://microservices.io). Although is a TODO application, it is interesting because the microservices that compose it are written in different programming language or frameworks (Go, Python, Vue, Java, and NodeJS). With this design you will experiment with multiple build tools and environments. 

## Components
In each folder you can find a more in-depth explanation of each component:

1. [Users API](/users-api) is a Spring Boot application. Provides user profiles. At the moment, does not provide full CRUD, just getting a single user and all users.
2. [Auth API](/auth-api) is a Go application, and provides authorization functionality. Generates [JWT](https://jwt.io/) tokens to be used with other APIs.
3. [TODOs API](/todos-api) is a NodeJS application, provides CRUD functionality over user's TODO records. Also, it logs "create" and "delete" operations to [Redis](https://redis.io/) queue.
4. [Log Message Processor](/log-message-processor) is a queue processor written in Python. Its purpose is to read messages from a Redis queue and print them to standard output.
5. [Frontend](/frontend) Vue application, provides UI.

## Architecture

Take a look at the components diagram that describes them and their interactions.
![microservice-app-example](/arch-img/Microservices.png)


____
Este proyecto integra en un mismo entorno todas las piezas fundamentales de la administración moderna de plataformas: contenedorización, orquestación, autoscaling, redes internas, publicación de imágenes, CI/CD y monitoreo centralizado.
La aplicación es un sistema compuesto por varios microservicios —auth, users, todos, log-processor y frontend— que se comunican entre sí a través de HTTP y Redis.

El objetivo del proyecto fue construir, desplegar y operar esta arquitectura sobre un clúster Kubernetes local ejecutándose dentro de GitHub Codespaces mediante kind (Kubernetes IN Docker), generando un entorno totalmente reproducible, portable y automatizado.

El trabajo incluye:

Construcción de imágenes con Docker

Despliegue en Kubernetes usando Deployments, Services e Ingress

Autoscaling con Horizontal Pod Autoscaler (HPA)

Secrets de Kubernetes para configuración segura

Publicación de imágenes en GitHub Container Registry (GHCR)

Pipeline de CI en GitHub Actions

Instalación de Prometheus y Grafana para monitoreo

Pruebas con carga real para verificar el escalado automático

Este README resume qué se implementó, cómo funciona y cuáles fueron los principales aprendizajes y dificultades enfrentadas.

 1. Contenedorización con Docker

Cada microservicio del proyecto cuenta con un Dockerfile propio:

auth-api

users-api

todos-api

log-message-processor

frontend

Las imágenes se construyen localmente y también de forma automática mediante GitHub Actions, publicándose en GHCR con tags como:

ghcr.io/<owner>/microapp-auth-api:latest

 Aprendizaje

Construir imágenes multi-servicio.

Entender la diferencia entre entorno local, Codespaces y runtime en Kubernetes.

Resolver dependencias de lenguaje (Java, Go, Node.js, Python).

 2. Kubernetes en Codespaces con kind

El entorno se compone de:

Un devcontainer.json con Docker-in-Docker habilitado.

Un Makefile con tareas como:

make kind-up

make kind-down

make deploy

make kctx

El clúster kind corre dentro del contenedor del Codespace y permite desplegar toda la aplicación.

 Aprendizaje

Inicialización de clúster kind.

Carga de imágenes externas desde GHCR.

Despliegue automatizado de manifests.

 3. Networking: Services + Ingress

Cada microservicio expone un Service ClusterIP, permitiendo comunicación interna:

auth-api.microapp
users-api.microapp
todos-api.microapp
redis.microapp


Y un Ingress Controller Nginx conduce todo el tráfico externo hacia el frontend.

 Aprendizaje

Modelar comunicación entre microservicios con DNS interno.

Configurar Ingress en entornos con restricciones (Codespaces).

Entender puertos, targets, selectors y labels.

 4. Autoscaling con HPA

El todos-api cuenta con un Horizontal Pod Autoscaler configurado al 50% de uso de CPU:

minReplicas: 1

maxReplicas: 5

Durante pruebas reales, el HPA escaló de 1 → 5 réplicas cuando el CPU aumentó, y posteriormente disminuyó cuando se redujo la carga.

 Aprendizaje

Importancia del metrics-server en clusters locales.

Visualizar métricas con kubectl top.

Interpretar estados y eventos del HPA.

 5. Secrets en Kubernetes

El proyecto utiliza un secrets-example.yaml donde se definen las claves necesarias del sistema y las variables sensibles, con valores dummy para evitar exponer datos privados.

En el clúster real, los secrets se crean con:

kubectl create secret generic microapp-secrets ...

 Aprendizaje

Buenas prácticas para no almacenar secretos reales.

Cómo referenciar secrets desde Deployments.

Cómo evitar exposición accidental en repos públicos.

 6. GitHub Actions – Build & Push a GHCR

Se implementó un pipeline CI que:

Compila cada microservicio

Construye las imágenes

Las publica en GHCR

El job de despliegue se eliminó ya que el proyecto utiliza un clúster local (kind), no un clúster remoto.

 Aprendizaje

Cómo autenticar GHCR desde Actions.

Normalización de tags.

Optimización de pipelines multi-servicio.

 7. Monitoreo: Prometheus + Grafana

Se instaló un stack de monitoreo mediante Helm.

Prometheus recolecta métricas del cluster.

Grafana permite visualización.

El HPA depende del metrics-server, que también fue desplegado y corregido.

Acceso mediante:

kubectl port-forward svc/grafana 3000:3000 -n monitoring

 Aprendizaje

Diferencia entre metrics-server y Prometheus.

Cómo se integran los componentes del ecosistema CNCF.

Problemas de certificado en metrics-server en entornos de Docker-in-Docker.

# Principales Dificultades Encontradas
1. Fallo del metrics-server en entornos Docker-in-Docker

El clúster kind no tenía acceso a los certificados necesarios, por lo que kubectl top fallaba.
Se solucionó usando el flag recomendado:

--kubelet-insecure-tls


Y agregando argumentos al deployment.

2. Ingress Controller en Codespaces

Codespaces maneja un proxy interno, por lo que no se podía usar hostPorts ni NodePort.
La solución fue:

Usar el addon de Codespaces para exponer puertos.

Delegar el tráfico al Ingress Controller por túneles internos.

3. Comunicación entre frontend y APIs

El frontend original estaba escrito para localhost, por lo que fue necesario:

Redirigir /api/* vía Ingress

Ajustar configuración para entornos de Kubernetes

4. HPA no escalaba al principio

Causas:

Metrics-server no funcionaba.

Recursos sin requests definidos.

Valores CPU demasiado bajos.

Tras corregir:

 El autoscaling funcionó perfectamente.

5. Push a GHCR – tags inválidos

GitHub requiere nombres:

en minúscula

sin espacios

sin símbolos raros

Fue necesario introducir un paso:

echo "owner_lowercase=${GITHUB_REPOSITORY_OWNER,,}" >> $GITHUB_OUTPUT

6. Desplegar microservicios Java, Go, Node y Python juntos

Cada stack tenía particularidades:

Spring Boot con H2

Echo (Go) con puertos configurables

Node scripts con build para frontend

Python con requirements

Esto fue uno de los retos más grandes del proyecto.

# Conclusiones

Este proyecto permitió integrar de forma práctica todos los componentes esenciales de la administración de plataformas:

Docker y contenedores multi-servicio

Kubernetes como entorno de orquestación

Redes internas y enrutamiento externo con Ingress

Autoscaling real mediante HPA

Gestión segura de secretos

CI/CD moderno con GitHub Actions + GHCR

Monitoreo profesional con Prometheus y Grafana

Pruebas reales en un entorno replicable con kind + Codespaces

Más allá de cumplir con los requisitos académicos, esta arquitectura representa una versión simplificada pero muy realista de cómo empresas modernas administran microservicios en la nube.

[Url del video que muestra el funcionamiento](https://icesiedu-my.sharepoint.com/:v:/g/personal/1007148696_u_icesi_edu_co1/IQDE4ebRDAf4Sb4FDSVlB2UhAXKO7LhF1YH-SMQN50dWZgQ?e=KAdSgc)
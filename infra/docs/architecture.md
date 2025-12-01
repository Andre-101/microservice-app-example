# Architecture — Microservice App

## 1. Componentes

- **frontend**: SPA en Vue.js que usa JWT para autenticación.
- **auth-api** (Go): expone `/login`, genera tokens JWT y se comunica con `users-api`.
- **users-api** (Spring Boot): expone datos de usuarios.
- **todos-api** (Node.js): expone CRUD de TODOs, usa JWT para autorización y publica eventos en Redis.
- **log-message-processor** (Python): consume eventos de Redis y los procesa (simula logging y Zipkin).

## 2. Networking interno

- Todos los pods viven en el namespace `microapp`.
- Servicios principales:
  - `auth-api` → puerto 8000 (login).
  - `users-api` → puerto 8083.
  - `todos-api` → puerto 8082.
  - `redis` → puerto 6379.
  - `frontend-service` → puerto 80.

## 3. Ingress

- **Ingress Controller**: Nginx Ingress desplegado con Helm en el namespace `ingress-nginx` (`ingress-nginx-controller`).
- **Ingress Rule** `microapp-ingress` (namespace `microapp`):
  - `/` → `frontend-service` (sirve la SPA).
  - `/login` → `auth-api` (login).
  - `/todos` → `todos-api` (gestión de tareas).

El frontend construye las URLs a partir de `window.location.protocol + '//' + window.location.host`, por lo que todas las peticiones van a `http://<host>/...` y el Ingress se encarga de enrutar a cada microservicio.

En laboratorio (kind + Codespaces) se accede a través de:

```text
http://localhost:8080/
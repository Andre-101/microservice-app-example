# Deployment Guide — Microservice App (Codespaces + kind)

## 1. Requisitos previos

- Repositorio en GitHub con este código.
- GitHub Codespaces habilitado.
- GitHub Container Registry (GHCR) habilitado en tu cuenta.

## 2. Preparar Codespaces

1. Haz clic en **Code → Create Codespace on main**.
2. Codespaces detectará `.devcontainer/devcontainer.json` y creará el entorno.
3. Espera a que termine el `post-create` (instala kubectl, kind, helm).
4. En una terminal dentro del Codespace ejecuta:

```bash
make kind-up
make deploy-base
make ingress-up

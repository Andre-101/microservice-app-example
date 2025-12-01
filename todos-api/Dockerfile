FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .

ENV TODO_API_PORT=8082
EXPOSE 8082

CMD ["node", "server.js"]

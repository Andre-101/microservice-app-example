FROM golang:1.22-alpine AS build
WORKDIR /app
COPY . .
RUN go mod init auth-api || true
RUN go mod tidy || true
RUN go build -o auth-api .

FROM alpine:3.19
WORKDIR /app
COPY --from=build /app/auth-api /usr/local/bin/auth-api

ENV AUTH_API_PORT=8000
EXPOSE 8000

CMD ["auth-api"]

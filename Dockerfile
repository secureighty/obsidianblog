FROM node:22-slim AS builder
WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json* .
RUN npm ci
COPY . .
RUN npx quartz build

FROM nginxinc/nginx-unprivileged:latest
WORKDIR /usr/share/nginx/html
COPY --from=builder /usr/src/app/public/ .

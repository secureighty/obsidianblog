FROM node:22-slim AS builder
WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json* .
RUN npm ci
COPY . .
RUN npx quartz build

FROM node:18.18.1-alpine AS build

WORKDIR /usr/src/app

COPY package*.json .

RUN npm install .

COPY . .

RUN npx @11ty/eleventy

FROM httpd:2.4

RUN sed -i 's/80/8080/g' /usr/local/apache2/conf/httpd.conf

COPY --from=build /usr/src/app/public /usr/local/apache2/htdocs/

RUN chmod -R 777 /usr/local/apache2/htdocs/
RUN chmod -R 777 /usr/local/apache2/logs/
FROM node:22-slim AS builder
WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json* .
RUN npm ci
COPY . .
RUN npx quartz build

# Use a lightweight Node.js base image for serving
FROM node:22-slim AS runner
WORKDIR /usr/src/app

# Install a lightweight web server
RUN npm install -g http-server

# Copy built files from builder stage
COPY --from=builder /usr/src/app/public /usr/src/app/public

# Expose port 8080 and run the server
EXPOSE 8080
CMD ["http-server", "public", "-p", "8080"]

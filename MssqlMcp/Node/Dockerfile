# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code and TypeScript config
COPY tsconfig.json ./
COPY src ./src

# Build the application
RUN npm run build

# Runtime stage
FROM node:20-alpine AS runtime
WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Create a non-root user
RUN adduser -D -s /bin/sh mcpuser && chown -R mcpuser:mcpuser /app
USER mcpuser

# Set environment variables (can be overridden at runtime)
ENV SERVER_NAME=""
ENV DATABASE_NAME=""
ENV READONLY="false"
ENV CONNECTION_TIMEOUT="30"
ENV TRUST_SERVER_CERTIFICATE="false"

# Entry point
ENTRYPOINT ["node", "dist/index.js"]
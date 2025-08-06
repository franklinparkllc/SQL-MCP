# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for building)
# Skip the prepare script during install
RUN npm ci --ignore-scripts

# Copy source code and TypeScript config
COPY tsconfig.json ./
COPY src ./src

# Build the application
RUN npm run build

# Runtime stage
FROM node:20-alpine AS runtime
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only (skip prepare script)
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

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
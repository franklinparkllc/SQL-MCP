# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY MssqlMcp.sln ./
COPY MssqlMcp/MssqlMcp.csproj ./MssqlMcp/
COPY MssqlMcp.Tests/MssqlMcp.Tests.csproj ./MssqlMcp.Tests/

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . .

# Build the application
RUN dotnet build -c Release --no-restore
RUN dotnet publish -c Release --no-build -o /app/publish MssqlMcp/MssqlMcp.csproj

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine AS runtime
WORKDIR /app

# Install required dependencies for SQL Server connectivity
RUN apk add --no-cache icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib

# Copy published application
COPY --from=build /app/publish .

# Create a non-root user
RUN adduser -D -s /bin/sh mcpuser && chown -R mcpuser:mcpuser /app
USER mcpuser

# Set environment variable for connection string
ENV CONNECTION_STRING=""

# Entry point
ENTRYPOINT ["./MssqlMcp"]
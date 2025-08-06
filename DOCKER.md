# Docker Support for MSSQL MCP Server

This guide explains how to build and run the MSSQL MCP server implementations using Docker.

## 📋 Prerequisites

- Docker Desktop or Docker Engine installed
- Docker Compose (usually included with Docker Desktop)
- Access to a SQL Server or Azure SQL Database

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/SQL-MCP.git
cd SQL-MCP
```

### 2. Configure Environment Variables

Copy the example environment file and update it with your database credentials:

```bash
cp .env.example .env
```

Edit `.env` with your preferred text editor and update the connection details.

### 3. Build the Docker Images

#### Using PowerShell (Windows):
```powershell
.\build-docker.ps1
```

#### Using Bash (Linux/macOS):
```bash
./build-docker.sh
```

#### Build Options:
- Build only .NET implementation: `.\build-docker.ps1 -Target dotnet`
- Build only Node.js implementation: `.\build-docker.ps1 -Target node`
- Build without cache: `.\build-docker.ps1 -NoBuildCache`

### 4. Run the Containers

```bash
# Run both implementations
docker-compose up

# Run only .NET implementation
docker-compose up mssql-mcp-dotnet

# Run only Node.js implementation
docker-compose up mssql-mcp-node

# Run in detached mode (background)
docker-compose up -d
```

## 🔧 Configuration

### Environment Variables

#### .NET Implementation
- `CONNECTION_STRING`: Full SQL Server connection string

Example connection strings:
```bash
# Local SQL Server with SQL Authentication
CONNECTION_STRING="Server=host.docker.internal;Database=test;User ID=sa;Password=YourPassword;TrustServerCertificate=True"

# Azure SQL Database with Azure AD
CONNECTION_STRING="Server=tcp:myserver.database.windows.net,1433;Initial Catalog=mydb;Encrypt=Mandatory;Authentication=Active Directory Interactive"
```

#### Node.js Implementation
- `SERVER_NAME`: SQL Server hostname
- `DATABASE_NAME`: Database name
- `READONLY`: Set to "true" for read-only access
- `CONNECTION_TIMEOUT`: Connection timeout in seconds (default: 30)
- `TRUST_SERVER_CERTIFICATE`: Set to "true" to trust self-signed certificates

## 🐳 Using with MCP Clients

### VS Code Agent

1. Update your VS Code settings to use the Docker container:

```json
{
  "mcp": {
    "servers": {
      "mssql-docker": {
        "type": "stdio",
        "command": "docker",
        "args": ["run", "--rm", "-i", "mssql-mcp:dotnet"],
        "env": {
          "CONNECTION_STRING": "Your connection string here"
        }
      }
    }
  }
}
```

### Claude Desktop

1. Update your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "mssql-docker": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "mssql-mcp:node"],
      "env": {
        "SERVER_NAME": "your-server.database.windows.net",
        "DATABASE_NAME": "your-database",
        "READONLY": "false"
      }
    }
  }
}
```

## 🔨 Advanced Usage

### Building for Different Platforms

```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t mssql-mcp:dotnet ./MssqlMcp/dotnet
```

### Using with Docker Registry

```bash
# Build and push to registry
.\build-docker.ps1 -Target all -Push -Registry "myregistry.azurecr.io"
```

### Running with SQL Server Container

Uncomment the SQL Server service in `docker-compose.yml` to run a local SQL Server instance:

```yaml
sqlserver:
  image: mcr.microsoft.com/mssql/server:2022-latest
  container_name: mssql-server
  environment:
    ACCEPT_EULA: "Y"
    SA_PASSWORD: "YourStrongPassword123"
    MSSQL_PID: "Developer"
  ports:
    - "1433:1433"
  volumes:
    - sqlserver_data:/var/opt/mssql
  networks:
    - mcp-network
```

Then update your connection strings to use `sqlserver` as the server name.

## 🔍 Troubleshooting

### Connection Issues

1. **"Cannot connect to SQL Server"**
   - Ensure your SQL Server is accessible from Docker
   - Use `host.docker.internal` instead of `localhost` for local databases
   - Check firewall settings

2. **"Authentication failed"**
   - Verify your credentials in the `.env` file
   - For Azure AD authentication, ensure you have the necessary permissions

3. **"Container exits immediately"**
   - Check logs: `docker-compose logs mssql-mcp-dotnet`
   - Verify environment variables are set correctly

### Debugging

View container logs:
```bash
# View logs for all containers
docker-compose logs

# View logs for specific container
docker-compose logs mssql-mcp-node

# Follow logs in real-time
docker-compose logs -f
```

Execute commands in running container:
```bash
docker exec -it mssql-mcp-dotnet /bin/sh
```

## 🧹 Cleanup

Remove containers and networks:
```bash
docker-compose down
```

Remove containers, networks, and volumes:
```bash
docker-compose down -v
```

Remove Docker images:
```bash
docker rmi mssql-mcp:dotnet mssql-mcp:node
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [SQL Server Docker Images](https://hub.docker.com/_/microsoft-mssql-server)
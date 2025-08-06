#!/usr/bin/env pwsh
# PowerShell script to build Docker images for MSSQL MCP

param(
    [Parameter()]
    [ValidateSet("all", "dotnet", "node")]
    [string]$Target = "all",
    
    [Parameter()]
    [switch]$NoBuildCache,
    
    [Parameter()]
    [switch]$Push,
    
    [Parameter()]
    [string]$Registry = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Building MSSQL MCP Docker images..." -ForegroundColor Green

# Function to build Docker image
function Build-DockerImage {
    param(
        [string]$Context,
        [string]$Dockerfile,
        [string]$Tag,
        [bool]$NoCache
    )
    
    Write-Host "`nBuilding $Tag..." -ForegroundColor Yellow
    
    $buildArgs = @(
        "build",
        "-t", $Tag,
        "-f", $Dockerfile,
        $Context
    )
    
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    
    & docker $buildArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build $Tag"
        exit 1
    }
    
    Write-Host "Successfully built $Tag" -ForegroundColor Green
}

# Build .NET implementation
if ($Target -eq "all" -or $Target -eq "dotnet") {
    $dotnetTag = "mssql-mcp:dotnet"
    if ($Registry) {
        $dotnetTag = "$Registry/mssql-mcp:dotnet"
    }
    
    Build-DockerImage `
        -Context "./MssqlMcp/dotnet" `
        -Dockerfile "./MssqlMcp/dotnet/Dockerfile" `
        -Tag $dotnetTag `
        -NoCache $NoBuildCache
        
    if ($Push -and $Registry) {
        Write-Host "`nPushing $dotnetTag to registry..." -ForegroundColor Yellow
        docker push $dotnetTag
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to push $dotnetTag"
            exit 1
        }
        Write-Host "Successfully pushed $dotnetTag" -ForegroundColor Green
    }
}

# Build Node.js implementation
if ($Target -eq "all" -or $Target -eq "node") {
    $nodeTag = "mssql-mcp:node"
    if ($Registry) {
        $nodeTag = "$Registry/mssql-mcp:node"
    }
    
    Build-DockerImage `
        -Context "./MssqlMcp/Node" `
        -Dockerfile "./MssqlMcp/Node/Dockerfile" `
        -Tag $nodeTag `
        -NoCache $NoBuildCache
        
    if ($Push -and $Registry) {
        Write-Host "`nPushing $nodeTag to registry..." -ForegroundColor Yellow
        docker push $nodeTag
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to push $nodeTag"
            exit 1
        }
        Write-Host "Successfully pushed $nodeTag" -ForegroundColor Green
    }
}

Write-Host "`nBuild complete!" -ForegroundColor Green
Write-Host "`nTo run the containers, use:" -ForegroundColor Cyan
Write-Host "  docker-compose up mssql-mcp-dotnet  # For .NET implementation"
Write-Host "  docker-compose up mssql-mcp-node    # For Node.js implementation"
Write-Host "  docker-compose up                   # For both implementations"
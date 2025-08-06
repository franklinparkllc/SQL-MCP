#!/bin/bash
# Bash script to build Docker images for MSSQL MCP

set -e

# Default values
TARGET="all"
NO_CACHE=""
PUSH=false
REGISTRY=""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --target <all|dotnet|node>  Build specific implementation (default: all)"
            echo "  --no-cache                  Build without using cache"
            echo "  --push                      Push images to registry"
            echo "  --registry <registry>       Docker registry to push to"
            echo "  -h, --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Building MSSQL MCP Docker images...${NC}"

# Function to build Docker image
build_docker_image() {
    local context=$1
    local dockerfile=$2
    local tag=$3
    
    echo -e "\n${YELLOW}Building $tag...${NC}"
    
    docker build $NO_CACHE -t "$tag" -f "$dockerfile" "$context"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully built $tag${NC}"
    else
        echo -e "${RED}Failed to build $tag${NC}"
        exit 1
    fi
}

# Build .NET implementation
if [ "$TARGET" == "all" ] || [ "$TARGET" == "dotnet" ]; then
    DOTNET_TAG="mssql-mcp:dotnet"
    if [ -n "$REGISTRY" ]; then
        DOTNET_TAG="$REGISTRY/mssql-mcp:dotnet"
    fi
    
    build_docker_image "./MssqlMcp/dotnet" "./MssqlMcp/dotnet/Dockerfile" "$DOTNET_TAG"
    
    if [ "$PUSH" == true ] && [ -n "$REGISTRY" ]; then
        echo -e "\n${YELLOW}Pushing $DOTNET_TAG to registry...${NC}"
        docker push "$DOTNET_TAG"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully pushed $DOTNET_TAG${NC}"
        else
            echo -e "${RED}Failed to push $DOTNET_TAG${NC}"
            exit 1
        fi
    fi
fi

# Build Node.js implementation
if [ "$TARGET" == "all" ] || [ "$TARGET" == "node" ]; then
    NODE_TAG="mssql-mcp:node"
    if [ -n "$REGISTRY" ]; then
        NODE_TAG="$REGISTRY/mssql-mcp:node"
    fi
    
    build_docker_image "./MssqlMcp/Node" "./MssqlMcp/Node/Dockerfile" "$NODE_TAG"
    
    if [ "$PUSH" == true ] && [ -n "$REGISTRY" ]; then
        echo -e "\n${YELLOW}Pushing $NODE_TAG to registry...${NC}"
        docker push "$NODE_TAG"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully pushed $NODE_TAG${NC}"
        else
            echo -e "${RED}Failed to push $NODE_TAG${NC}"
            exit 1
        fi
    fi
fi

echo -e "\n${GREEN}Build complete!${NC}"
echo -e "\n${CYAN}To run the containers, use:${NC}"
echo "  docker-compose up mssql-mcp-dotnet  # For .NET implementation"
echo "  docker-compose up mssql-mcp-node    # For Node.js implementation"
echo "  docker-compose up                   # For both implementations"
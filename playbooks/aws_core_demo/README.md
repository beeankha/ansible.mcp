# AWS Core MCP Server Integration with Ansible

This directory contains files that demonstrate how to integrate the AWS Core MCP Server with Ansible using the stdio transport. The AWS Core MCP server acts as a proxy/gateway to other AWS MCP servers. This demo uses the `aws-foundation` role which includes AWS Knowledge Server (documentation search) and AWS API Server (CLI commands).

Reference: [AWS Core MCP Server Documentation](https://awslabs.github.io/mcp/servers/core-mcp-server)

## Overview

The [AWS Core MCP Server](https://awslabs.github.io/mcp/servers/core-mcp-server) implements a dynamic proxy server strategy that routes requests to specialized AWS MCP servers based on role-based environment variables.

**This demo uses the `aws-foundation` role** which provides:
- **AWS Knowledge Server**: Search AWS documentation, get regional availability, read documentation pages
- **AWS API Server**: Execute and suggest AWS CLI commands

## Files

- **`demo.yml`** - Demonstration playbook showcasing AWS Core MCP server connection
- **`inventory.yaml`** - Inventory configuration for the AWS Core MCP server
- **`manifest.json`** - MCP server manifest defining connection details

## Prerequisites

### 1. Python and uvx
The AWS Core MCP server requires Python 3.12+ and uvx (Python package runner):

```bash
# Check if uvx is installed
uvx --version

# Install uv (which includes uvx) if needed
# macOS/Linux:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip:
pip install uv
```

### 2. AWS Credentials
Configure AWS credentials for Knowledge Server and API Server features:

```bash
# Option 1: AWS Profile (recommended)
aws configure --profile default

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_REGION=us-east-1
```

### 3. Ansible MCP Collection
```bash
ansible-galaxy collection install ansible.mcp
```

## Configuration

### manifest.json
Defines the stdio connection to the AWS Core MCP server:

```json
{
  "awslabs.core-mcp-server": {
    "type": "stdio",
    "command": "uvx",
    "args": ["awslabs.core-mcp-server@latest"],
    "description": "AWS Core MCP Server - Gateway to AWS MCP servers"
  }
}
```

### inventory.yaml
Ansible inventory with role-based server configuration:

```yaml
all:
  children:
    mcp_servers:
      hosts:
        aws_core_server:
          ansible_connection: ansible.mcp.mcp
          ansible_mcp_server_name: awslabs.core-mcp-server
          ansible_mcp_server_args: []
          ansible_mcp_server_env:
            AWS_REGION: us-east-1
            AWS_PROFILE: default
            FASTMCP_LOG_LEVEL: ERROR
            aws-foundation: "true"
          ansible_mcp_manifest_path: "{{ playbook_dir }}/manifest.json"
```

### Key Configuration Parameters

- **ansible_mcp_server_name**: References the server in manifest.json (`awslabs.core-mcp-server`)
- **ansible_mcp_server_env**: Environment variables including:
  - `AWS_REGION`: Your AWS region
  - `AWS_PROFILE`: AWS CLI profile name
  - `FASTMCP_LOG_LEVEL`: Log level (ERROR, INFO, DEBUG)
  - `aws-foundation`: Set to `"true"` to enable AWS Knowledge and API servers (enabled in this demo)
  - You can add other role variables (e.g., `solutions-architect: "true"`, `security-identity: "true"`, `serverless-architecture: "true"`) to enable additional server groups

### Available Roles

The AWS Core MCP Server supports role-based server configuration through environment variables. Each role corresponds to a logical grouping of MCP servers commonly used together for specific use cases.

**This demo uses the `aws-foundation` role**, but you can enable any combination of the available roles (such as `solutions-architect`, `security-identity`, `serverless-architecture`, etc.).

For complete documentation, see the [AWS Core MCP Server documentation](https://awslabs.github.io/mcp/servers/core-mcp-server#role-based-server-configuration).

## Usage

### Running the Demo

```bash
ansible-playbook -i inventory.yaml demo.yml
```

### What the Demo Does

The playbook demonstrates:

1. **Server Connection**: Connects to AWS Core MCP server via stdio transport using uvx
2. **Server Discovery**: Retrieves server information (name, version, protocol)
3. **Tool Discovery**: Lists all available tools from the aws-foundation role

**Tools available:**
- **AWS Knowledge Server tools**: search_documentation, read_documentation, list_regions, get_regional_availability, recommend
- **AWS API Server tools**: suggest_aws_commands, call_aws

## Customization

### Using Different Roles

This demo uses `aws-foundation` by default, but you can enable additional roles by updating the inventory environment variables. You can enable multiple roles simultaneously:

**Example: Add Solutions Architect tools**
```yaml
ansible_mcp_server_env:
  AWS_REGION: us-east-1
  AWS_PROFILE: default
  aws-foundation: "true"
  solutions-architect: "true"
```

**Example: Serverless Development**
```yaml
ansible_mcp_server_env:
  AWS_REGION: us-east-1
  AWS_PROFILE: default
  aws-foundation: "true"
  serverless-architecture: "true"
```

**Example: Security + Monitoring**
```yaml
ansible_mcp_server_env:
  AWS_REGION: us-east-1
  AWS_PROFILE: default
  aws-foundation: "true"
  security-identity: "true"
  monitoring-observability: "true"
```

See the [Available Roles](#available-roles) section for the complete list of roles and their included servers.

# AWS CCAPI MCP Server Integration with Ansible

This directory contains files that demonstrate how to integrate the **AWS CCAPI MCP Server** with Ansible using the stdio transport. The CCAPI MCP server allows you to create and manage AWS infrastructure resources programmatically via the Cloud Control API.

This demo playbook creates a **VPC** and an **EC2 instance** within that VPC using the CCAPI MCP server.

Reference: [AWS CCAPI MCP Server Documentation](https://awslabs.github.io/mcp/servers/ccapi-mcp-server)

---

## Overview

The AWS CCAPI MCP Server is designed to manage AWS infrastructure using AWS Cloud Control API tools. This demo uses a playbook that interacts with the MCP server to:

- Connect via stdio transport using `uvx`
- Discover available tools on the MCP server
- Create a VPC with configurable CIDR, DNS, and tags
- Dynamically select the latest AMI
- Launch one or more EC2 instances in the newly created VPC

> ⚠️ Note: The CCAPI MCP server is interactive — some tools may prompt for confirmation during execution.

---

## Files

- **`demo.yml`** – Demonstration playbook showcasing CCAPI MCP server connection and resource creation  
- **`inventory.yaml`** – Inventory configuration for the AWS CCAPI MCP server  
- **`manifest.json`** – MCP server manifest defining connection details  
- **`group_vars/all.yml`** – Variables for VPC, EC2, region, AMI, and key pair  

---

## Prerequisites

### 1. Python and uvx

The AWS CCAPI MCP server requires Python 3.12+ and **uvx**:

```bash
# Check if uvx is installed
uvx --version

# Install uv (includes uvx) if needed
# macOS/Linux:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip:
pip install uv
```

### 2. AWS Credentials

Configure AWS credentials for creating infrastructure:

```bash
# Option 1: AWS Profile (recommended)
aws configure --profile default

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_REGION=us-east-1
```

### 3. Ansible MCP Collection

Install the Ansible MCP collection:

```bash
ansible-galaxy collection install ansible.mcp
ansible-galaxy collection install amazon.aws
```

## Configuration

### manifest.json

Defines the stdio connection to the AWS CCAPI MCP 

```bash
server:
{
  "awslabs.ccapi-mcp-server": {
    "type": "stdio",
    "command": "uvx",
    "args": ["awslabs.ccapi-mcp-server@latest"],
    "description": "AWS CCAPI MCP Server - Manages AWS infrastructure via Cloud Control API"
  }
}
```

### inventory.yaml

Ansible inventory with server configuration:

```bash
all:
  children:
    mcp_servers:
      hosts:
        aws_ccapi_server:
          ansible_connection: ansible.mcp.mcp
          ansible_mcp_server_name: awslabs.ccapi-mcp-server
          ansible_mcp_server_args: []
          ansible_mcp_server_env:
            AWS_REGION: "{{ AWS_REGION }}"
            AWS_PROFILE: "{{ AWS_PROFILE }}"
            FASTMCP_LOG_LEVEL: ERROR
          ansible_mcp_manifest_path: "{{ playbook_dir }}/manifest.json"
```

### group_vars/all.yml

All key variables are defined in group_vars/all.yml:

```bash
# AWS Configuration
AWS_REGION: "us-east-1"
AWS_PROFILE: "default"

# VPC Configuration
vpc_name: "demo-vpc"
vpc_cidr: "10.1.0.0/16"
vpc_dns_support: true
vpc_dns_hostnames: true
vpc_tags:
  Name: "{{ vpc_name }}"

# EC2 Configuration
ec2_key_pair: "demo-key"
ec2_count: 1
ec2_tags:
  Name: "demo-ec2"

# AMI Selection
ami_owner_id: "137112412989"           # Amazon official owner for Amazon Linux
ami_name_pattern: "amzn2-ami-hvm-*-x86_64-gp2"
```

## Usage

### Running the Demo

```bash
ansible-playbook -i playbooks/aws_ccapi_demo/inventory.yaml playbooks/aws_ccapi_demo/demo.yml
```

### What the Demo Does

1. **Server Connection**: Connects to AWS CCAPI MCP server via stdio transport using uvx
2. **Server Discovery**: Retrieves server information (name, version, protocol)
3. **Tool Discovery**: Lists all available CCAPI MCP tools
4. **Dynamic AMI Selection**: Automatically selects the latest AMI based on ami_name_pattern
5. **Infrastructure Creation**: Creates a VPC and one or more EC2 instances

## Customization

You can customize variables in ``group_vars/all.yml``:

- **VPC settings**: ``vpc_name``, ``vpc_cidr``, ``vpc_dns_support``, ``vpc_dns_hostnames``, ``vpc_tags``
- **EC2 settings**: ``ec2_instance_type``, ``ec2_count``, ``ec2_key_pair``, ``ec2_tags``
- **AMI selection**: ``ami_owner_id``, ``ami_name_pattern``
- **AWS region/profile**: ``AWS_REGION``, ``AWS_PROFILE``

_Example_: to create a larger VPC and multiple EC2 instances:

```bash
vpc_name: "custom-vpc"
vpc_cidr: "10.2.0.0/16"
ec2_instance_type: "t3.medium"
ec2_count: 3
ami_name_pattern: "amzn2-ami-hvm-*-x86_64-gp2"
```

## Notes

- The CCAPI MCP server is designed for interactive sessions; certain tool actions may require manual confirmation.
- This playbook is intended for manual verification and demonstration purposes.
- Ensure your AWS credentials have sufficient IAM permissions for EC2 and VPC operations.
- The dynamic AMI selection ensures you always use the latest official Amazon Linux AMI, but you can adjust the ``ami_name_pattern`` for other OS or versions.
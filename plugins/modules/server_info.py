# -*- coding: utf-8 -*-

# Copyright (c) 2025 Red Hat, Inc.
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r"""

module: server_info

short_description: Retrieve MCP server information

author:
    - Bianca Henderson (@beeankha)

description:
    - This module retrieves server information from an MCP (Model Context Protocol) server.
    - The server information is returned from the initialization step of the MCP connection.
    - This module requires the MCP connection plugin to be configured.

version_added: "1.0.0"

notes:
    - This module requires the MCP connection plugin (ansible.mcp.mcp) to be configured.
    - The connection plugin must be initialized before this module can retrieve server information.
    - Server information is retrieved from the MCP server's initialization response.
"""

EXAMPLES = r"""
- name: Retrieve server info from GitHub MCP server
  ansible.mcp.server_info:
  register: gh_mcp_server_info

- name: Display server info
  ansible.builtin.debug:
    var: gh_mcp_server_info

- name: Retrieve server info from AWS IAM MCP server
  ansible.mcp.server_info:
  register: aws_mcp_server_info

- name: Display AWS server info
  ansible.builtin.debug:
    var: aws_mcp_server_info
"""

RETURN = r"""
server_info:
    description: Server information returned from the MCP server initialization.
    returned: success
    type: dict
    contains:
        protocolVersion:
            description: MCP protocol version supported by the server.
            returned: success
            type: str
            sample: "2025-03-26"
        serverInfo:
            description: Information about the MCP server.
            returned: success
            type: dict
            contains:
                name:
                    description: Name of the MCP server.
                    returned: success
                    type: str
                    sample: "github-server"
                version:
                    description: Version of the MCP server.
                    returned: success
                    type: str
                    sample: "1.0.0"
        capabilities:
            description: Capabilities supported by the MCP server.
            returned: success
            type: dict
"""

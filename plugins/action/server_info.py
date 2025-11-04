# -*- coding: utf-8 -*-

# Copyright (c) 2025 Red Hat, Inc.
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from ansible.errors import AnsibleActionFail
from ansible.module_utils.connection import Connection
from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):
    """Action plugin to retrieve MCP server information."""

    def run(self, tmp=None, task_vars=None):
        """Execute the server_info action.

        Returns:
            dict: Ansible result dictionary containing server_info
        """
        if task_vars is None:
            task_vars = {}

        result = super(ActionModule, self).run(tmp, task_vars)
        result["changed"] = False

        # Ensure we're using the MCP connection
        connection_type = self._play_context.connection
        if not connection_type or not connection_type.endswith(".mcp"):
            raise AnsibleActionFail(
                "Connection type %s is not valid for server_info module, "
                "please use fully qualified name of MCP connection type."
                % connection_type
            )

        # Get socket path from connection
        socket_path = self._connection.socket_path
        if socket_path is None:
            raise AnsibleActionFail("socket_path is not available from connection")

        try:
            # Use Connection class to call server_info on the connection plugin
            conn = Connection(socket_path)
            server_info = conn.server_info()

            result["server_info"] = server_info
            return result

        except Exception as e:
            raise AnsibleActionFail("Failed to retrieve server info: %s" % str(e))

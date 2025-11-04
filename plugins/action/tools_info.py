# -*- coding: utf-8 -*-

# Copyright (c) 2025 Red Hat, Inc.
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from ansible.module_utils.connection import Connection
from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):
        """Perform the process of the action plugin"""
        connection_name = self._play_context.connection.split(".")[-1]

        result = super(ActionModule, self).run(task_vars=task_vars)

        if connection_name != "mcp":
            # It is supported only with mcp connection plugin
            result["failed"] = True
            result["msg"] = (
                "connection type %s is not valid for tools_info module,"
                " please use fully qualified name of mcp connection type"
                % self._play_context.connection
            )
            return result

        conn = Connection(self._connection.socket_path)
        tools = conn.list_tools().get("tools", [])

        return dict(changed=False, tools=tools)

from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):
        result = {"changed": False}

        conn = self._connection  # MCP connection plugin

        try:
            # server_info is a method in your connection plugin
            result["mcp_server_info"] = conn.server_info()  # ✅ only one call

            result["available_tools"] = conn.list_tools()
            result["query_result"] = (
                "Inspect 'available_tools' to find the correct name for your SQL tool."
            )
            # ------------------------------

        except Exception as e:
            result["failed"] = True
            result["msg"] = str(e)

        return result

"""Claude Code から呼び出す MCP サーバー本体。

自然言語の質問を受け取り、内部で LangChain Agent（get_schema / execute_sql）を
実行して、自然文の回答と実際に実行された SQL・生の結果データをまとめて返す
単一の粗粒度ツール ``ask_database`` を公開する。
"""

import json

from mcp.server.mcpserver import MCPServer

from mcp_server.agent import run_agent
from mcp_server.settings import load_settings

mcp = MCPServer("text2sql")


def _extract_executed_queries(messages: list) -> list[dict]:
    """AIMessage の tool_calls と対応する ToolMessage から execute_sql の入出力を抽出する。

    Agent の自由文の要約だけに頼らず、実際に実行された生の SQL と生の結果データを
    レスポンスに含めるための処理。
    """
    tool_call_names = {}
    for message in messages:
        for tool_call in getattr(message, "tool_calls", None) or []:
            tool_call_names[tool_call["id"]] = tool_call["name"]

    executed = []
    for message in messages:
        if type(message).__name__ != "ToolMessage":
            continue
        if tool_call_names.get(message.tool_call_id) != "execute_sql":
            continue
        try:
            payload = json.loads(message.content)
        except (TypeError, json.JSONDecodeError):
            payload = {"raw": message.content}
        executed.append(payload)
    return executed


def _extract_final_answer(messages: list) -> str:
    for message in reversed(messages):
        if type(message).__name__ == "AIMessage" and message.content:
            return message.content
    return ""


@mcp.tool()
def ask_database(question: str) -> dict:
    """自然言語の質問から IRIS 上のデータに対する SQL を生成・実行し、結果を返す。

    スキーマ取得・SQL生成・SQL実行までを内部で完結させ、
    自然文の回答に加えて、実際に実行された SQL 文と生の実行結果データを返す。
    """
    settings = load_settings()
    result = run_agent(settings, question)
    messages = result["messages"]
    return {
        "answer": _extract_final_answer(messages),
        "executed_queries": _extract_executed_queries(messages),
    }


def main() -> None:
    mcp.run()


if __name__ == "__main__":
    main()

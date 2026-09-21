"""LangChain Agent が利用する Tool 定義。

- get_schema: 引数なし。対象クラス全件分のスキーマ定義テキストをまとめて返す。
- execute_sql: SELECT 文のみを許可し、IRIS 上で実行して結果を返す。
  SELECT 以外は実行前に拒否し、ツール内でのリトライは行わない。
"""

from langchain_core.tools import tool

from mcp_server import iris_client
from mcp_server.settings import Settings


def _is_select_only(sql: str) -> bool:
    body = sql.strip().rstrip(";").strip()
    if not body.upper().startswith("SELECT"):
        return False
    # 複数文（スタックド・クエリ）を拒否する。
    return ";" not in body


def build_tools(settings: Settings) -> list:
    @tool
    def get_schema() -> str:
        """対象テーブル全ての定義（DDL相当のテキスト）をまとめて取得する。SQL を作成する前に必ず呼び出すこと。"""
        return iris_client.fetch_schema_text(settings)

    @tool
    def execute_sql(sql: str) -> dict:
        """SELECT 文を IRIS 上で実行し、列名と結果行を返す。SELECT 文以外は拒否される。"""
        if not _is_select_only(sql):
            return {"error": "SELECT文のみ実行できます。", "sql": sql}
        try:
            result = iris_client.execute_select(settings, sql)
        except Exception as e:  # noqa: BLE001 - エラーはそのまま最終結果として返す方針
            return {"error": str(e), "sql": sql}
        result["sql"] = sql
        return result

    return [get_schema, execute_sql]

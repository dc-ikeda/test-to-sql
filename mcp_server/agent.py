"""LangChain Agent（o4-mini + get_schema/execute_sql）の構築。"""

from langchain.agents import create_agent
from langchain_openai import ChatOpenAI

from mcp_server.settings import Settings
from mcp_server.tools import build_tools

SYSTEM_PROMPT = """あなたは InterSystems IRIS 上のデータに対する Text-to-SQL アシスタントです。
必ず次の手順に従ってください。

1. まず get_schema ツールを呼び出し、テーブル定義（DDL相当のテキスト）を取得する。
2. get_schema で取得した定義に実在するテーブル・カラムのみを使って SELECT 文を組み立てる。
3. 組み立てた SELECT 文を execute_sql ツールに渡して実行する。
4. execute_sql がエラーを返した場合は、別の SQL を考え直して再実行せず、
   エラー内容をそのまま利用者への回答に含める。
5. SELECT 文以外（更新・削除・DDL等）を実行しようとしてはいけない。
"""

# get_schema -> execute_sql の最小構成（model -> tools -> model -> tools -> model）を
# 安全マージン込みで許容する値。Agent が実行エラー後に別の SQL を試すなどの
# 「暗黙のリトライ」を重ねられないように、意図的に小さく制限する。
RECURSION_LIMIT = 10


def build_agent(settings: Settings):
    model = ChatOpenAI(model=settings.openai_model, api_key=settings.openai_api_key)
    tools = build_tools(settings)
    return create_agent(model, tools, system_prompt=SYSTEM_PROMPT)


def run_agent(settings: Settings, question: str) -> dict:
    agent = build_agent(settings)
    result = agent.invoke(
        {"messages": [{"role": "user", "content": question}]},
        config={"recursion_limit": RECURSION_LIMIT},
    )
    return result

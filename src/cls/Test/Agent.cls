Class Test.Agent Extends %AI.Agent
{
/// Provider to use
Parameter PROVIDER = "OpenAI";

/// Model to use
Parameter MODEL = "gpt-4.1-mini";

/// API key -- expand from environment variable at runtime
Parameter APIKEY = "@{env:OPENAI_API_KEY}";

/// 使用するツールセットのクラス名を指定。複数ある時はカンマ区切り
Parameter TOOLSETS = "Test.Tools";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
あなたは InterSystems IRIS 上のデータに対する Text-to-SQL アシスタントです。
必ず次の手順に従ってください。

1. まず GetSchema ツールを呼び出し、テーブル定義（DDL相当のテキスト）を取得する。
2. GetSchema で取得した定義に実在するテーブル・カラムのみを使って SELECT 文を組み立てる。
3. 組み立てた SELECT 文を ExecuteSql ツールに渡して実行する。
4. ExecuteSql がエラーを返した場合は、別の SQL を考え直して再実行せず、エラー内容をそのまま利用者への回答に含める。
5. SELECT 文以外（更新・削除・DDL等）を実行しようとしてはいけない。

回答は必ず以下のJSON形式で返してください。
- 出力はJSONのみ。
- Markdownや文字列は禁止。
- JSONは1行のコンパクト形式で返してください。
- 存在しない情報は空文字または空配列にしてください。
- ExecuteSqlから取得したJSONをそのまま返してください。

}

/// チャット
ClassMethod TestChat(question As %String) As %Status
{
    s agent = ..%New()
    $$$ThrowOnError(agent.%Init())
    s policy = ##class(%AI.Policy.ConsoleAuth).%New()
    , policy.AlwaysAllow=1
    d agent.ToolManager.SetAuthPolicy(policy)

    // Create chat session
    s session = agent.CreateSession()


    // ファイルの中身をREADする
    s response = agent.Chat(session, question)
    w !, response.Content, !
    
    q $$$OK
}
}

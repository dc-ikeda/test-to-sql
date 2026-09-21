/// 自然言語で検索するエージェントを起動するクラス
Class Test.AgentTool Extends %AI.Tool
{

/// IRISのデータベースを自然言語で検索する
/// 引数：SQLクエリ
/// 戻り：JSON文字列(検索結果)
ClassMethod AskDatabase(question as %String) As %DynamicObject
{
    #Dim json as %DynamicObject

    k ^ZzKou
    s ^ZzKou=question

    s agent = ##class(Test.Agent).%New()
    $$$ThrowOnError(agent.%Init())

    s ^ZzKou("通過")=1

    s policy = ##class(%AI.Policy.ConsoleAuth).%New()
    , policy.AlwaysAllow=1
    d agent.ToolManager.SetAuthPolicy(policy)

    s ^ZzKou("通過")=2

    // Create chat session
    s session = agent.CreateSession()

    s ^ZzKou("通過")=3

    // ファイルの中身をREADする
    s ^ZzKou("start")=$zh
    s res = agent.Chat(session, question)
    s ^ZzKou("start-end")=$zh-$g(^ZzKou("start"))

    s resTxt = res.Content
    s ^ZzKou("resTet")=resTxt
    i ($l(resTxt,$c(10))=2){
        s resTxt = $p(resTxt, $c(10), 2)
    }
    s json = {}.%FromJSON(resTxt)

    s ^ZzKou("json")=json
    
    q json
}
}

/// 自然言語で検索するエージェントを起動するクラス
Class Test.AgentTool Extends %AI.Tool
{

/// IRISのデータベースを自然言語で検索する 
/// 引数：検索の為の自然言語 
/// 戻り：JSONオブジェクト(検索結果) 
ClassMethod AskDatabase(question as %String) As %DynamicObject
{
    s agent = ##class(Test.Agent).%New()
    $$$ThrowOnError(agent.%Init())
    
    s policy = ##class(%AI.Policy.ConsoleAuth).%New()
    , policy.AlwaysAllow=1
    d agent.ToolManager.SetAuthPolicy(policy)

    s session = agent.CreateSession() // セッション作成
    s res = agent.Chat(session, question)

    s resTxt = res.Content
    s json = {}.%FromJSON(resTxt)
    
    return json
}
}

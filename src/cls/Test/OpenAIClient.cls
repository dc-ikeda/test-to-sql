/// OpenAI Chat Completions API を直接呼び出すユーティリティクラス。
Class Test.OpenAIClient
{

/// .envファイルのフルパス
Parameter ENVFILE = "D:\Work\Git\text2sql\.env";

/// 自然言語でのSQL実行テスト
ClassMethod TestSQL(question as %String)
{
    // SQLクエリ取得
    s query = ..MakeQuery(question)

    i ($zcvt($e(query, 1, 6),"l")="select"){
        w !,$$$FormatText("実行クエリ : %1", query), $$$NL, $$$NL

        // select句のみ実行する
        s stmt = ##class(%SQL.Statement).%New(1)
        d stmt.%Prepare(query)
        s rset = stmt.%Execute()
        d rset.%Display()
    }else{
        w !, $$$FormatText("select句ではない : %1", query)
    }
}

/// プロンプト文字列をそのまま user メッセージ1件として OpenAI に送信し、
/// 応答テキスト（choices[0].message.content）を返す。
ClassMethod MakeQuery(question As %String) As %String [ Language = python ]
{
    import json, iris
    import urllib.request
    import urllib.error


    # .env を簡易パースして OPENAI_API_KEY / OPENAI_MODEL を取り出す
    env = iris.cls(__name__).GetAPIKey()
    api_key = env._Get("OPENAI_API_KEY", "")
    model = env._Get("OPENAI_MODEL", "o4-mini")
    if not api_key:
        raise ValueError("OPENAI_API_KEY が .env に設定されていません。")

    # プロンプト作成
    prompt = iris.cls(__name__).GetPrompt(question)

    # OpenAIにアクセス
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
    }).encode("utf-8")

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=body,
        method="POST",
        headers={
            "Authorization": "Bearer " + api_key,
            "Content-Type": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            payload = json.loads(res.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI API がエラーを返しました ({e.code}): {detail}")

    return payload["choices"][0]["message"]["content"]
}

/// プロンプトを生成する
ClassMethod GetPrompt(input as %String) as %String
{
    #define NL $c(13,10)

    s prom = ""

    // ルール記載
    s prom = prom_"# 順守するルール"_$$$NL
    , prom = prom_"1. テーブル情報を参照し、SQLのSELECT文を組み立てる事"
    , prom = prom_"2. 回答はSQL文のみを1行（またはそのまま実行可能な形）で返してください。説明文・前置き・マークダウンのコードブロックは一切含めないでください。"


    // テーブル情報取得
    s prom = prom_$$$NL_"# テーブル情報"_$$$NL
    s tblNm = ""
    f {
        s tblNm = $o(^Test.SQLText(tblNm),1,clsDt) q:tblNm=""
        s prom = prom_clsDt_$$$NL_$$$NL
    }

    s prom = prom_$$$NL_"# 構築するクエリ情報"_$$$NL
    , prom = prom_input_$$$NL

    q prom
}

/// 環境ファイル.envからOpenAIのAPIキー等の情報を取得する
ClassMethod GetAPIKey() as %DynamicObject
{
    s ret = {}

    s stm = ##class(%Stream.FileCharacter).%New()
	, stm.TranslateTable = "UTF8"
	, stm.Filename       = ..#ENVFILE
	while('stm.AtEnd){
		s line = stm.ReadLine(, .sc, .eol, .term) $$$ThrowOnError(sc)
        continue:($e(line,1)="#")
		
        s kmk = $p(line,"=",1)
        , val = $p(line,"=",2, *)

        d ret.%Set(kmk, val)
	}

    q ret
}

/// Test.SQLTextクラスを継承したデータクラスから、クエリ情報を出力
ClassMethod OutputSQLText()
{
    s sts = ##class(%SQL.Statement).%New()
    d sts.%PrepareClassQuery("%Dictionary.ClassDefinitionQuery","SubclassOf")
    s rset = sts.%Execute("Test.SQLText")
    while (rset.%Next()) {
		s clsNm=rset.%Get("Name")
        w !,clsNm
		d $ClassMethod(clsNm, "OutputSQLText")
	}
}
}

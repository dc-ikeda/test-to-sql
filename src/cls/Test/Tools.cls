Class Test.Tools  Extends %AI.Tool
{

/// 引数なし。対象クラス全件分のスキーマ定義テキストをまとめて返す。
/// 対象テーブル全ての定義（DDL相当のテキスト）をまとめて取得する。SQL を作成する前に必ず呼び出すこと。
ClassMethod GetSchema() As %DynamicObject
{
    #define NL $c(13,10)

    s (tblNm, prom) = ""
    f {
        s tblNm = $o(^Test.SQLText(tblNm),1,clsDt) q:tblNm=""
        s prom = prom_clsDt_$$$NL_$$$NL
    }

    q {"sql": (prom)}
}

/// SELECT 文のみを許可し、IRIS 上で実行して結果を返す。
/// SELECT 以外は実行前に拒否し、ツール内でのリトライは行わない。
/// SELECT 文を IRIS 上で実行し、列名と結果行を返す。SELECT 文以外は拒否される。
ClassMethod ExecuteSql(query as %String)  As %DynamicObject
{
    #define NL $c(13,10)

    s res = {}
    try {
        i ($zcvt($e(query, 1, 6),"l") = "select"){
            // select句のみ実行する
            s stmt = ##class(%SQL.Statement).%New(1)
            $$$ThrowOnError(stmt.%Prepare(query))

            s rset = stmt.%Execute()
            throw:(rset.%SQLCODE<0) ##class(%Exception.SQL).CreateFromSQLCODE(rset.%SQLCODE,rset.%Message)

            s res.Status = "OK"
            s res.Body = []

            s meta = rset.%GetMetadata()
            s columns = meta.columns
            k colList
            f pos = 1:1:meta.columnCount {
                s colList(pos) = columns.GetAt(pos).colName
            }

            // データを詰める
            while( rset.%Next()){
                s ary = []
                f pos = 1:1:meta.columnCount {
                    s kmk = colList(pos)
                    , val = rset.%GetData(pos)
                    s obj = {}.%Set(kmk, val)
                    d ary.%Push(obj)
                }
                d res.Body.%Push(ary)
            }

        }else{
            s res.Status = "Error"
            s res.Message = $$$FormatText("select句ではない : %1", query)
        }
    }catch e {
        s res.Status = "Error"
        s res.Message = e.DisplayString()
    }
    
    q res
}
}

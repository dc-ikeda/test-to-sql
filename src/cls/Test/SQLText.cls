Include (%occMessages, %occReferenceStorage, %occKeyword)

Class Test.SQLText Extends %Projection.AbstractProjection
{
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    // code here...
    q ..OutputSQLText(cls)
}

ClassMethod OutputSQLText(clsNm as %String) as %Status
{
    #define NL $c(13,10)
    #define TAB $c(9)

    try {
        k ^Test.SQLText(clsNm)
        d ..GetTableInfo(.clsDt, .idxDt, clsNm)
        q:('$d(clsDt))


        // ------------------------------------------------------------
        // 列取得クエリ
        s query(1) = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH, DESCRIPTION"
        , query(2) = "FROM INFORMATION_SCHEMA.COLUMNS"
        , query(3) = "WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?"
        , query(4) = "ORDER BY ORDINAL_POSITION"
        , query = 4

        s tableNm = $p(clsNm, ".", *)
        s sqlTblNm = $g(clsDt("sqlTblNm"))
        s name = $s(sqlTblNm'="":sqlTblNm, 1:tableNm)
        s schema = $tr($p(clsNm, ".", 1, *-1), ".", "_")
        s sqlNm = schema_"."_name
        
        s (clmList, idKey, dlm, capBk) = ""

        s stmt = ##class(%SQL.Statement).%New()
        s rset = stmt.%ExecDirect(, .query, schema, name)
        while( rset.%Next() ){
            s clmNm = rset.%Get("COLUMN_NAME")
            , clmType = rset.%Get("DATA_TYPE")
            , clmNullable = rset.%Get("IS_NULLABLE")
            , clmLength = rset.%Get("CHARACTER_MAXIMUM_LENGTH")
            , clmDescription = rset.%Get("DESCRIPTION")

            continue:$e(clmNm,1)="%" // 非公開プロパティはスキップ

            i (clmNm = "ID"){
                i ($d(idxDt("primary"))) {
                    s keyNm = $o(idxDt("primary", ""), 1, paramList)
                    s clmList = clmList_$$$TAB_"PRIMARY KEY ("_paramList_")"
                }else{
                    s clmList = clmList_$$$TAB_"id INT AUTO_INCREMENT PRIMARY KEY"
                }
            }else{
                s cap = $g(clsDt("propDt", clmNm, "cap"))
                , valList = $g(clsDt("propDt", clmNm, "vallist"))
                , dipList = $g(clsDt("propDt", clmNm, "diplist"))
                
                s type = clmType_$s(clmLength="":"", 1:"("_clmLength_")")

                // displist
                i (dipList'=""){
                    s (dips, dlm) = ""
                    f pos=2:1:$l(dipList,","){
                        s dips = dips_dlm_$$$FormatText("表示:「%1」 -> 値:'%2'", $p(dipList, ",", pos), $p(valList, ",", pos)), dlm = ", "
                    }
                    s cap = cap_" ("_dips_")"
                }

                // not null
                s notNull = $s(clmNullable="YES":"", 1:" NOT NULL")


                s clmList = clmList_dlm_capBk_$$$NL_$$$TAB_$$$FormatText("%1 %2%3", clmNm, type, notNull)
                s capBk = " -- "_cap
            }

            s dlm = ","
        }
        s clmList = clmList_capBk_$$$NL
        
        
        
        // ------------------------------------------------------------
        // SQL文生成
        s ret = ""
        s ret = ret_$g(clsDt("descript"))_$$$NL
        s ret = ret_$$$FormatText("CREATE TABLE %1 (%2", sqlNm, $$$NL)
        s ret = ret_idKey
        s ret = ret_clmList
        s ret = ret_");"

        // ------------------------------------------------------------
        // Index文生成
        i ($d(idxDt("index"))){
            s ret = ret_$$$NL

            s idxKey = ""
            f { s idxKey = $o(idxDt("index", idxKey), 1, paramList) q:idxKey=""
                s data = $g(idxDt("index", idxKey, "Data"))
                s ret = ret_"CREATE INDEX "_idxKey_" ON "_sqlNm_" ("_paramList_")"
                s ret = ret_$s(data="":";"_$$$NL, 1:" INCLUDE ("_data_");"_$$$NL)
            }
        }

        s ^Test.SQLText(clsNm) = ret
    } catch (e) {
        w !,$system.Status.GetErrorText(e.AsStatus())
        return e.AsStatus()
    }
    return $$$OK
}


/// クラス情報の取得
ClassMethod GetTableInfo(Output clsDt, Output idxDt, clsNm as %String)
{
    k clsDt, idxDt

    s classDef = ##class(%Dictionary.ClassDefinition).%OpenId(clsNm)    
    s super = classDef.Super
    q:(super'["%Persistent")

    // クラス定義
    s clsDt("sqlTblNm") = classDef.SqlTableName
    , clsDt("descript") = classDef.Description

    // プロパティ情報取得
    s props = classDef.Properties
    i ($IsObject(props)){
        f i = 1:1:props.Count(){
            s prop = props.GetAt(i)
            s propNm = prop.Name // プロパティ名
            continue:$e(propNm,1)="%" // 非公開プロパティはスキップ

            s propType = prop.Type // 型
            , propSqlName = prop.SqlFieldName // SQL名
            , required = prop.Required  // 必須

            s key = $s(propSqlName'="":propSqlName,1:propNm)
            , clsDt("propDt", key, "name") = propNm
            , clsDt("propDt", key, "type") = propType
            , clsDt("propDt", key, "sqlName") = propSqlName
            , clsDt("propDt", key, "cap") = $$$defStorageSubMemberGet(clsNm, $$$cCLASSproperty, propNm, $$$cPROPparameter, "CAPTION")
            , clsDt("propDt", key, "maxlen") = $$$defStorageSubMemberGet(clsNm, $$$cCLASSproperty, propNm, $$$cPROPparameter, "MAXLEN")
            , clsDt("propDt", key, "diplist") = $$$defStorageSubMemberGet(clsNm, $$$cCLASSproperty, propNm, $$$cPROPparameter, "DISPLAYLIST")
            , clsDt("propDt", key, "vallist") = $$$defStorageSubMemberGet(clsNm, $$$cCLASSproperty, propNm, $$$cPROPparameter, "VALUELIST")
            , clsDt("propDt", key, "required") = required
        }
    }

    // インデックス情報取得
    k idxDt
    s indexes = classDef.Indices
    i ($IsObject(indexes)){
        f i = 1:1:indexes.Count(){
            s index = indexes.GetAt(i)
            s indexNm = index.Name // インデックス名

            i (index.PrimaryKey) {
                s idxDt("primary", indexNm) = index.Properties
            }else{
                s idxDt("index", indexNm) = index.Properties
                , idxDt("index", indexNm, "Data") = index.Data
            }
        }
    }
}
}

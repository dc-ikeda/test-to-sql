/// [サンプルテーブル] 患者情報テーブル
/// 患者ID(patientID)をユニークキーとして、患者情報を取得する
Class Test.Patient Extends (%Persistent, Test.SQLText) [ CompileAfter = Test.SQLText ]
{
Index primIdx On PatientId [ PrimaryKey, Unique ];

Index nameIdx On (KanaName, Birthday, Sex);

/// 患者ID
Property PatientId As %String(CAPTION = "患者ID", MAXLEN = 10) [ SqlColumnNumber = 2, Required  ];

/// 漢字氏名
Property Name As %String(CAPTION = "漢字氏名", MAXLEN = 50) [ SqlColumnNumber = 3 ];

/// カナ氏名
Property KanaName As %String(CAPTION = "カナ氏名", MAXLEN = 50) [ SqlColumnNumber = 4 ];

/// 生年月日
Property Birthday As %Date(CAPTION = "生年月日", FORMAT = 3) [ SqlColumnNumber = 5 ];

/// 性別
Property Sex As %String(CAPTION = "性別", DISPLAYLIST = ",男性,女性,その他", VALUELIST = ",M,F,O") [ SqlColumnNumber = 6 ];

/// ABO血液型（A:A型, B:B型, O:O型, AB:AB型）
Property BloodType As %String(CAPTION = "ABO血液型", DISPLAYLIST = ",A型,B型,O型,AB型", VALUELIST = ",A,B,O,AB") [ SqlColumnNumber = 7 ];

/// RH血液型
Property RhType As %String(CAPTION = "血液型", DISPLAYLIST = ",+,-", VALUELIST = ",+,-") [ SqlColumnNumber = 8 ];

/// 登録日時
Property SaveDate As %TimeStamp(CAPTION = "登録日時") [ SqlColumnNumber = 9 ];

/// 更新日時
Property UpdateDate As %TimeStamp(CAPTION = "更新日時") [ SqlColumnNumber = 10 ];

/// コンパイル後に実行される
Projection CreateProjection As Test.SQLText;

Storage Default
{
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientId</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>KanaName</Value>
</Value>
<Value name="5">
<Value>Birthday</Value>
</Value>
<Value name="6">
<Value>Sex</Value>
</Value>
<Value name="7">
<Value>BloodType</Value>
</Value>
<Value name="8">
<Value>RhType</Value>
</Value>
<Value name="9">
<Value>SaveDate</Value>
</Value>
<Value name="10">
<Value>UpdateDate</Value>
</Value>
<Value name="11">
<Value>test</Value>
</Value>
</Data>
<DataLocation>^Test.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^Test.PatientD</IdLocation>
<IndexLocation>^Test.PatientI</IndexLocation>
<StreamLocation>^Test.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

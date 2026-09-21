/// [サンプルテーブル] 処方テーブル
/// 処方情報を格納する
/// 患者テーブル(Test.Patient)とは、患者ID(patientID)で紐づく
Class Test.Order20 Extends (%Persistent, Test.SQLText) [ CompileAfter = Test.SQLText ]
{
Index primIdx On (PatientId, OrderNo, PrescriptionNo, RpNo, SeqNo) [ PrimaryKey, Unique ];

/// 患者ID
Property PatientId As %String(CAPTION = "患者ID", MAXLEN = 10) [ SqlColumnNumber = 2 ];

/// オーダ番号
Property OrderNo As %String(CAPTION = "オーダ番号", MAXLEN = 15) [ SqlColumnNumber = 3 ];

/// 処方箋番号
Property PrescriptionNo As %Integer(CAPTION = "処方箋番号") [ SqlColumnNumber = 4 ];

/// Rp番号
Property RpNo As %Integer(CAPTION = "Rp番号") [ SqlColumnNumber = 5 ];

/// Seq番号
Property SeqNo As %Integer(CAPTION = "Seq番号") [ SqlColumnNumber = 6 ];

/// 処方日
Property PrescriptionDate As %Date(CAPTION = "処方日", FORMAT = 7) [ SqlColumnNumber = 7 ];

/// 入外区分
Property InOutMode As %Integer(CAPTION = "入外区分", DISPLAYLIST = ",外来,院内", VALUELIST = ",0,1") [ SqlColumnNumber = 8 ];

/// 診療科コード
Property DepartmentCd As %Integer(CAPTION = "診療科コード") [ SqlColumnNumber = 9 ];

/// 医師コード
Property DoctorCd As %Integer(CAPTION = "医師コード") [ SqlColumnNumber = 10 ];

/// 用法コード
Property UsageCode as %String(CAPTION="用法コード")[ SqlColumnNumber = 11];

/// 薬品コード
Property Code as %String(CAPTION="薬品コード")[ SqlColumnNumber = 12];

/// 薬品名称
Property Name as %String(CAPTION="薬品名称")[ SqlColumnNumber = 13];

/// 分量
Property Quantity as %String(CAPTION="分量")[ SqlColumnNumber = 14 ];

/// 登録日時
Property SaveDate As %TimeStamp(CAPTION = "登録日時") [ SqlColumnNumber = 15 ];

/// 更新日時
Property UpdateDate As %TimeStamp(CAPTION = "更新日時") [ SqlColumnNumber = 16 ];

/// コンパイル後に実行される
Projection CreateProjection As Test.SQLText;

Storage Default
{
<Data name="Order20DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientId</Value>
</Value>
<Value name="3">
<Value>OrderNo</Value>
</Value>
<Value name="4">
<Value>PrescriptionNo</Value>
</Value>
<Value name="5">
<Value>RpNo</Value>
</Value>
<Value name="6">
<Value>SeqNo</Value>
</Value>
<Value name="7">
<Value>PrescriptionDate</Value>
</Value>
<Value name="8">
<Value>InOutMode</Value>
</Value>
<Value name="9">
<Value>DepartmentCd</Value>
</Value>
<Value name="10">
<Value>DoctorCd</Value>
</Value>
<Value name="11">
<Value>UsageCode</Value>
</Value>
<Value name="12">
<Value>Code</Value>
</Value>
<Value name="13">
<Value>Name</Value>
</Value>
<Value name="14">
<Value>Quantity</Value>
</Value>
<Value name="15">
<Value>SaveDate</Value>
</Value>
<Value name="16">
<Value>UpdateDate</Value>
</Value>
</Data>
<DataLocation>^Test.Order20D</DataLocation>
<DefaultData>Order20DefaultData</DefaultData>
<IdLocation>^Test.Order20D</IdLocation>
<IndexLocation>^Test.Order20I</IndexLocation>
<StreamLocation>^Test.Order20S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

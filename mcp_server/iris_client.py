"""IRIS への接続処理。

- Native API: ``^Test.SQLText(clsNm)`` グローバルからスキーマ定義テキストを取得する。
- DB-API: 生成された SQL を実行する。

注意（既知の落とし穴）: ``^Test.SQLText`` の中身は UTF-16LE でエンコードされている。
Native API の ``getString()`` をそのまま使うと文字化けするため、
``getBytes()`` で生バイト列を取得し ``.decode("utf-16-le")`` で明示的にデコードすること。
"""

import datetime
import json
from typing import Any

import iris

from mcp_server.settings import Settings

SCHEMA_GLOBAL_NAME = "Test.SQLText"

# IRIS DB-API の type_code。DATE/TIME/TIMESTAMP は内部表現（HOROLOG形式）で
# 定義されており、通常は自動的に datetime 型へ変換されるが、WHERE句を伴う
# JOIN クエリ等では変換されず生の内部表現（文字列/数値）のまま返ってくる
# ケースが確認されている（PoCで確認済みの既知の落とし穴）。
# そのため呼び出し側で type_code を見て明示的に正規化する。
_DATE_HOROLOG = 1091  # 1840-12-31 起点の日数
_TIME_HOROLOG = 1092  # 真夜中からの秒数
_TIMESTAMP_POSIX = 1093  # UNIX エポック秒
_HOROLOG_EPOCH = datetime.date(1840, 12, 31)


def _normalize_value(value: Any, type_code: int) -> Any:
    if value is None:
        return None
    if type_code == _DATE_HOROLOG and not isinstance(value, datetime.date):
        return (_HOROLOG_EPOCH + datetime.timedelta(days=int(value))).isoformat()
    if type_code == _TIME_HOROLOG and not isinstance(value, datetime.time):
        return str(datetime.timedelta(seconds=int(value)))
    if type_code == _TIMESTAMP_POSIX and not isinstance(value, datetime.datetime):
        return datetime.datetime.fromtimestamp(float(value)).isoformat()
    if isinstance(value, (datetime.date, datetime.datetime, datetime.time)):
        return value.isoformat()
    return value


def _connect(settings: Settings) -> iris.IRISConnection:
    return iris.connect(
        settings.iris_host,
        settings.iris_superserver_port,
        settings.iris_namespace,
        settings.iris_username,
        settings.iris_password,
    )


def load_target_classes(settings: Settings) -> list[str]:
    with open(settings.tables_config_path, encoding="utf-8") as f:
        config = json.load(f)
    return config["classes"]


def fetch_schema_text(settings: Settings) -> str:
    """config/tables.json に列挙された全クラスのスキーマ定義テキストを連結して返す。"""
    classes = load_target_classes(settings)
    conn = _connect(settings)
    try:
        irispy = iris.createIRIS(conn)
        parts = []
        for class_name in classes:
            raw = irispy.getBytes(SCHEMA_GLOBAL_NAME, class_name)
            parts.append(raw.decode("utf-16-le"))
        return "\n".join(parts)
    finally:
        conn.close()


def execute_select(settings: Settings, sql: str) -> dict[str, Any]:
    """SELECT 文を実行し、列名と行データを返す。呼び出し側で SELECT であることを検証済みの前提。"""
    conn = _connect(settings)
    try:
        cur = conn.cursor()
        cur.execute(sql)
        description = cur.description or []
        columns = [d[0] for d in description]
        type_codes = [d[1] for d in description]
        rows = cur.fetchmany(settings.max_result_rows)
        row_limit_exceeded = cur.fetchone() is not None
        cur.close()
        normalized_rows = [
            [_normalize_value(value, type_code) for value, type_code in zip(row, type_codes)]
            for row in rows
        ]
        return {
            "columns": columns,
            "rows": normalized_rows,
            "row_count": len(normalized_rows),
            "row_limit_exceeded": row_limit_exceeded,
        }
    finally:
        conn.close()

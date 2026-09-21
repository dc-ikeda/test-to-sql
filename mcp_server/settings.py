"""環境変数の読み込みと設定値の一元管理。"""

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

ROOT_DIR = Path(__file__).resolve().parents[1]
load_dotenv(ROOT_DIR / ".env")


@dataclass(frozen=True)
class Settings:
    iris_host: str
    iris_superserver_port: int
    iris_namespace: str
    iris_username: str
    iris_password: str
    openai_api_key: str
    openai_model: str
    max_result_rows: int
    tables_config_path: Path


def load_settings() -> Settings:
    return Settings(
        iris_host=os.environ["IRIS_HOST"],
        iris_superserver_port=int(os.environ["IRIS_SUPERSERVER_PORT"]),
        iris_namespace=os.environ["IRIS_NAMESPACE"],
        iris_username=os.environ["IRIS_USERNAME"],
        iris_password=os.environ["IRIS_PASSWORD"],
        openai_api_key=os.environ["OPENAI_API_KEY"],
        openai_model=os.environ.get("OPENAI_MODEL", "o4-mini"),
        max_result_rows=int(os.environ.get("MAX_RESULT_ROWS", "100")),
        tables_config_path=ROOT_DIR / "config" / "tables.json",
    )

import os
import yaml
from dotenv import load_dotenv
from pydantic import BaseModel

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(CURRENT_DIR, "settings.yaml")
ENV_PATH = os.path.join(CURRENT_DIR, ".env")

load_dotenv(ENV_PATH)


class DataBaseSettings(BaseModel):
    url: str
    schema_path: str


class Settings(BaseModel):
    database: DataBaseSettings

    @classmethod
    def load(cls, config_path: str = CONFIG_PATH) -> "Settings":
        with open(config_path, "r", encoding="utf-8") as f:
            raw_data = yaml.safe_load(f)

        db_url = os.getenv("DATABASE_URL")
        if not db_url:
            raise ValueError(
                "DATABASE_URL not founf in .env file. "
                f"Check, if file exist: {ENV_PATH}"
            )

        raw_data["database"]["url"] = db_url
        return cls(**raw_data)


settings = Settings.load()
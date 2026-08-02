import os
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


class DatabaseConnection:
    def __init__(self, dsn: str, schema_path: str):
        """
        :param dsn: Connection string (postgresql+psycopg2://user:pass@host:port/db)
        :param schema_path: Path to the .sql file with DDL
        """
        self.dsn = dsn
        self.schema_path = schema_path
        self.engine: Engine = create_engine(self.dsn)

    def init_schema(self) -> None:
        """Executes the DDL file to create tables (if they don't already exist)."""
        if not os.path.exists(self.schema_path):
            raise FileNotFoundError(f"Schema not found: {self.schema_path}")

        with open(self.schema_path, "r", encoding="utf-8") as f:
            schema_sql = f.read()

        with self.engine.begin() as conn:
            conn.execute(text(schema_sql))

    def execute(self, query: str):
        """Runs a raw SQL query and returns fetched rows."""
        with self.engine.begin() as conn:
            result = conn.execute(text(query))
            return result.fetchall()

    def get_engine(self) -> Engine:
        """Returns the underlying SQLAlchemy engine — pass this to pandas.to_sql()."""
        return self.engine

    def close(self) -> None:
        self.engine.dispose()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
import os

import pandas as pd 
from Config import Settings, get_logger
from Infrastructure.Database import DatabaseConnection


CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)
SAVE_DATA_DIR = os.path.join(ROOT_DIR, "Data/Formated")
SQL_DIR = os.path.join(ROOT_DIR, "Analytics/SQL")

def main():
    FILE_PATH = os.path.join(SQL_DIR, "01_top_categories_by_revenue.sql")
    settings = Settings.load()
    logger = get_logger(__name__)

    con = DatabaseConnection(
        settings.database.url,
        settings.database.schema_path
    )
    con.init_schema()

    with open(FILE_PATH, "r", encoding="utf-8") as f:
        sql_query_result = con.execute(f.read())
        data_df = pd.DataFrame(sql_query_result)
    file_name = os.path.join(SAVE_DATA_DIR, "01_top_categories_by_revenue.csv")
    data_df.to_csv(file_name)

    logger.info(f"File saved on path {file_name}")


if __name__ == "__main__" : 
    main()

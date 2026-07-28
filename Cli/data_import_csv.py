import os
import pandas as pd
from Config import Settings, get_logger
from Infrastructure.Database import DatabaseConnection

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)
DATA_DIR = os.path.join(ROOT_DIR, "Data/Raw")


TABLE_LOAD_ORDER = [
    "geolocation",
    "product_category_name_translation",
    "customers",
    "sellers",
    "products",
    "orders",
    "order_items",
    "order_payments",
    "order_reviews",
]


def main():
    settings = Settings.load()
    logger = get_logger(__name__)

    con = DatabaseConnection(
        settings.database.url,
        settings.database.schema_path
    )
    con.init_schema()
    logger.info("Connection created, schema initialized")

    data_frames = _get_data_frames(logger)
    logger.info(f"Data frames created: {list(data_frames.keys())}")

    _data_frames_to_sql(data_frames=data_frames, con=con, logger=logger)

    data = con.execute("SELECT * FROM geolocation LIMIT 5")
    if str(data) is not None : 
        logger.info("Data Base was succesful initialize")


def _data_frames_to_sql(data_frames: dict, con: DatabaseConnection, logger) -> None:
    engine = con.get_engine()
    data_frames["order_reviews"] = data_frames["order_reviews"].drop_duplicates(
        subset=["review_id"], keep="first"
    )
    for table_name in TABLE_LOAD_ORDER:
        if table_name not in data_frames:
            logger.warning(f"Miss {table_name}: CSV not found")
            continue

        df = data_frames[table_name]
        df.to_sql(
            name=table_name,
            con=engine,
            if_exists="append",
            index=False,
        )
        logger.info(f"✓ {table_name}: Loaded {len(df)} rows")


def _get_data_frames(logger) -> dict:
    files = [os.path.join(DATA_DIR, f) for f in os.listdir(DATA_DIR)]
    data_frames = {
        _format_table_name(f): pd.read_csv(f) for f in files
    }
    return data_frames


def _format_table_name(table_name: str) -> str:
    return table_name.replace("olist_", "").replace("_dataset", "").replace(DATA_DIR+"/", "").replace(".csv", "")



if __name__ == "__main__":
    main()
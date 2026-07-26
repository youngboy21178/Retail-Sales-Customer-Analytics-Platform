from Config import Settings, get_logger
from Infrastructure.Database import DatabaseConnection


def main():
    settings = Settings.load()
    logger = get_logger(__name__)
    logger.debug(f"Setting = {settings}")

    con = DatabaseConnection(
        settings.database.url,
        settings.database.schema_path
    )
    logger.debug("Connection created")


if __name__ == "__main__":
    main()
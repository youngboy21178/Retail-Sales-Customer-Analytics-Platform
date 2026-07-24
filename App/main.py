from Config import Settings, get_logger


def main():
    settings = Settings.load()
    logger = get_logger(__name__)

    logger.debug(f"Setting = {settings}")


if __name__ == "__main__":
    main()
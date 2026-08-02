import logging
import sys


class ColorFormatter(logging.Formatter):
    GREY = "\033[90m"
    GREEN = "\033[32m"
    ORANGE = "\033[33m"
    RED = "\033[31m"
    BOLD_RED = "\033[1;31m"
    RESET = "\033[0m"

    FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"

    COLORS = {
        logging.DEBUG: GREY,
        logging.INFO: GREEN,
        logging.WARNING: ORANGE,
        logging.ERROR: RED,
        logging.CRITICAL: BOLD_RED,
    }

    def format(self, record: logging.LogRecord) -> str:
        color = self.COLORS.get(record.levelno, self.RESET)
        formatter = logging.Formatter(f"{color}{self.FORMAT}{self.RESET}", datefmt="%Y-%m-%d %H:%M:%S")
        return formatter.format(record)


def get_logger(name: str, level: int = logging.DEBUG) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(level)

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(ColorFormatter())
        logger.addHandler(handler)
        logger.propagate = False

    return logger



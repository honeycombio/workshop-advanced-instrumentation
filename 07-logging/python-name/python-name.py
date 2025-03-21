import asyncio
import datetime
import random
import logging
import requests
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from opentelemetry import trace

namesByYear = {
    2015: [
        "sophia",
        "jackson",
        "emma",
        "aiden",
        "olivia",
        "liam",
        "ava",
        "lucas",
        "mia",
        "noah",
    ],
    2016: [
        "sophia",
        "jackson",
        "emma",
        "aiden",
        "olivia",
        "lucas",
        "ava",
        "liam",
        "mia",
        "noah",
    ],
    2017: [
        "sophia",
        "jackson",
        "olivia",
        "liam",
        "emma",
        "noah",
        "ava",
        "aiden",
        "isabella",
        "lucas",
    ],
    2018: [
        "sophia",
        "jackson",
        "olivia",
        "liam",
        "emma",
        "noah",
        "ava",
        "aiden",
        "isabella",
        "caden",
    ],
    2019: [
        "sophia",
        "liam",
        "olivia",
        "jackson",
        "emma",
        "noah",
        "ava",
        "aiden",
        "aria",
        "grayson",
    ],
    2020: [
        "olivia",
        "noah",
        "emma",
        "liam",
        "ava",
        "elijah",
        "isabella",
        "oliver",
        "sophia",
        "lucas",
    ],
}

tracer = trace.get_tracer(__name__)
app = FastAPI()

# initialize logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# Create console handler and set level
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)

# Create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
console_handler.setFormatter(formatter)

# Add handler to logger
logger.addHandler(console_handler)

@app.get("/", response_class=HTMLResponse)
def home():
    return "service: <a href='/name'>/name</a>"


@app.get("/name")
async def name():
    logger.info("get_name received")
    year = get_year()
    logger.debug(f"get_year generated: Year: {year}")
    names = namesByYear[year]
    result = random.choice(names)
    logger.debug(f"name randomly chosen: {result}")

    return {
        "language": "Python",
        "year": year,
        "name": result,
        "generated": datetime.datetime.now().isoformat(),
    }


def get_random_int(max):
    return random.randint(1, max)


def get_year():
    try:
        response = requests.get("http://localhost:6001/year")
        response.raise_for_status()  # Raise an error for bad status codes
        data = response.json()
        return data.get("year")
    except requests.RequestException as e:
        logger.error(f"Error fetching year: {e}")
        return None

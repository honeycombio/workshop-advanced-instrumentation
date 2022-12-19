import asyncio
import random

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def home():
    return {"Hello": "World"}


@app.get("/year")
async def year():
    result = await get_year()
    return result


def get_random_int(max):
    return random.randint(1, max)


async def get_year():
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    rnd = get_random_int(250)
    await asyncio.sleep(rnd / 1000)
    # get a random element from the list of years
    year = random.choice(years)
    return year

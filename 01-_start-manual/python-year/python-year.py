import asyncio
import random

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/year")
async def year():
    # divide by 1000 to convert to milliseconds
    rnd = getRandomInt(250)
    await asyncio.sleep(rnd/1000)
    result = determineYear()
    return result


def getRandomInt(max):
    return random.randint(1, max)


def determineYear():
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    # get a random element from the list of years
    year = random.choice(years)
    return year

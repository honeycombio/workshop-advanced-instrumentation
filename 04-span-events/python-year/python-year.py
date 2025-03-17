import asyncio
import datetime
import random

from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from opentelemetry import trace

years = [2015, 2016, 2017, 2018, 2019, 2020]
tracer = trace.get_tracer(__name__)
app = FastAPI()


@app.get("/", response_class=HTMLResponse)
def home():
    return "service: <a href='/year'>/year</a>"


@app.get("/year")
async def year():
    span = trace.get_current_span()
    span.set_attribute("foo", "bar")

    asyncio.create_task(do_some_work())

    result = await get_year()
    return {
        "language": "Python",
        "year": result,
        "generated": datetime.datetime.now().isoformat()
    }

async def do_some_work():
    with tracer.start_as_current_span("some-work") as span:
        span.set_attribute("otel", "rocks")
        await asyncio.sleep(get_random_int(250) / 1000)
        # add span event and attributes
        span.add_event("my event", attributes={"more": "details"})
        await asyncio.sleep((get_random_int(150) + 100) / 1000)
        span.add_event("another event")


def get_random_int(max):
    return random.randint(1, max)


@tracer.start_as_current_span("getYear")
async def get_year():
    span = trace.get_current_span()
    rnd = get_random_int(250)
    span.set_attribute("random-index", rnd)

    # divide by 1000 to convert to milliseconds
    await asyncio.sleep(rnd / 1000)

    # get a random element from the list of years
    year = random.choice(years)
    span.set_attribute("year", year)

    return year

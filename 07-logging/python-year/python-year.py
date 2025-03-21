import asyncio
import datetime
import random
import logging
import os
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from opentelemetry import trace

years = [2015, 2016, 2017, 2018, 2019, 2020]
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
    return "service: <a href='/year'>/year</a>"


@app.get("/year")
async def year():
    span = trace.get_current_span()
    logger.info("getting year...")
    span.set_attribute("foo", "bar")

    asyncio.create_task(do_some_work())

    result = await get_year()
    logger.debug(f"year generated: {result}")
    return {
        "language": "Python",
        "year": result,
        "generated": datetime.datetime.now().isoformat(),
    }


async def do_some_work():
    with tracer.start_as_current_span("some-work") as span:
        span.set_attribute("otel", "rocks")
        logger.debug(f"do_some_work generated: Otel rocks")
        await asyncio.sleep(get_random_int(250) / 1000)
        # add span event and attributes
        span.add_event("my event", attributes={"more": "details"})
        await asyncio.sleep((get_random_int(150) + 100) / 1000)
        span.add_event("another event")
        logger.debug(f"do_some_work generated: Another event")
        asyncio.create_task(generate_linked_trace())


def get_random_int(max):
    return random.randint(1, max)


@tracer.start_as_current_span("getYear")
async def get_year():
    span = trace.get_current_span()
    rnd = get_random_int(250)
    span.set_attribute("random-index", rnd)
    logger.debug(f"get_year generated: Random index: {rnd}")
    # divide by 1000 to convert to milliseconds
    await asyncio.sleep(rnd / 1000)

    # get a random element from the list of years
    year = random.choice(years)
    span.set_attribute("year", year)
    logger.debug(f"get_year generated: Year: {year}")
    return year


async def generate_linked_trace():
    # get current span
    source_span = trace.get_current_span()
    # add link to new span with context from current span
    with tracer.start_as_current_span(
        "generated-span-root",
        context=trace.Context(),
        attributes={"depth": 1},
        links=[trace.Link(context=source_span.get_span_context())],
    ) as span:
        await asyncio.sleep(get_random_int(250) / 1000)
        await add_recursive_span(2, 5)


async def add_recursive_span(depth, max_depth):
    logger.debug(f"add_recursive_span generated: Depth: {depth}")
    with tracer.start_as_current_span(
        "generated-span", attributes={"depth": depth}
    ) as span:
        await asyncio.sleep(get_random_int(250) / 1000)

        if depth < max_depth:
            await add_recursive_span(depth + 1, max_depth)


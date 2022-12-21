import time
import random

from fastapi import FastAPI

from opentelemetry import trace

tracer = trace.get_tracer(__name__)

app = FastAPI()


@app.get("/year")
async def year():
    span = trace.get_current_span()
    span.set_attribute("foo", "bar")
    result = get_year()
    return result


def get_random_int(max):
    return random.randint(1, max)

@tracer.start_as_current_span("random-year")
def get_year():
    do_some_work()
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    # get a random element from the list of years
    year = random.choice(years)
    span = trace.get_current_span()
    span.set_attribute("random-year", year)

    return year

def do_some_work():
    with tracer.start_as_current_span("some-work") as span:
        span.set_attribute("otel", "rocks")
        rnd = get_random_int(250)
        span.set_attribute("random-sleep", rnd)
        time.sleep(rnd / 1000)


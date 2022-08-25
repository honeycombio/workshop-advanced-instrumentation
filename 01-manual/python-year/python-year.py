import asyncio
import random

from fastapi import FastAPI

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


# setup trace provider
tracer_provider = TracerProvider()
trace.set_tracer_provider(tracer_provider)
tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))

tracer = trace.get_tracer(__name__)

app = FastAPI()


@app.get("/year")
async def year():
    span = trace.get_current_span()
    span.set_attribute("foo", "bar")
    result = await get_year()
    return result


def get_random_int(max):
    return random.randint(1, max)


async def get_year():
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    # Start a new child span
    with tracer.start_as_current_span("getYear") as span:
        rnd = get_random_int(250)
        span.set_attribute("random-index", rnd)

        # divide by 1000 to convert to milliseconds
        await asyncio.sleep(rnd / 1000)

        # get a random element from the list of years
        year = random.choice(years)
        span.set_attribute("random-year", year)

    return year

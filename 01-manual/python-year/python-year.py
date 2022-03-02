import os
import asyncio
import random

from fastapi import FastAPI, Request
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import \
    OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (BatchSpanProcessor,
                                            ConsoleSpanExporter)

app = FastAPI()

# create the OTLP exporter to send data an insecure OpenTelemetry Collector
otlp_exporter = OTLPSpanExporter(
    endpoint="https://api.honeycomb.io",
    insecure=True
)

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer_provider().get_tracer(__name__)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(ConsoleSpanExporter())
)

@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/year")
async def year(request: Request):
    with tracer.start_span("getYear"):
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
import asyncio
import os
import random

from fastapi import FastAPI, Request, status
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import \
    OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Uncomment the line below if using ConsoleSpanExporter
# from opentelemetry.sdk.trace.export import ConsoleSpanExporter

app = FastAPI()

# Resource can be required for some backends, e.g. Jaeger
# If resource wouldn't be set - traces wouldn't appears in Jaeger
resource = Resource(attributes={
    "service.name": "python-year"
})

# create the OTLP exporter to send data to an insecure OpenTelemetry Collector
otlp_exporter = OTLPSpanExporter(
    endpoint="https://api.honeycomb.io", 
    insecure=True,
    headers=(
        ('x-honeycomb-team', os.getenv("HONEYCOMB_API_KEY", "")),
        ('x-honeycomb-dataset', os.getenv("HONEYCOMB_DATASET", ""))
        )
    )

trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer_provider().get_tracer(__name__)
trace.get_tracer_provider().add_span_processor(
    # If you'd like to see the OTel data in the console, use the ConsoleSpanExporter
    # BatchSpanProcessor(ConsoleSpanExporter())
    BatchSpanProcessor(otlp_exporter)
)

def getRandomInt(max):
    return random.randint(1, max)

async def determineYear():
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    # Start a new child span
    active_span = tracer.start_span("getYear")
    rnd = getRandomInt(250)
    active_span.set_attribute("random-index", rnd)
    # divide by 1000 to convert to milliseconds
    await asyncio.sleep(rnd/1000)
    # get a random element from the list of years
    year = random.choice(years)
    active_span.set_attribute("random-year", year)
    active_span.end()
    return year


# App
@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/year")
async def year(request: Request, status_code=status.HTTP_200_OK):
    with tracer.start_as_current_span("/year") as current_span:
        current_span.set_attribute("foo", "bar")
        result = await determineYear()
        return {"year": result}

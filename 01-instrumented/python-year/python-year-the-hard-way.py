import asyncio
import datetime
import os
import random

from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor


# setup common resource attributes
resource = Resource(attributes={"service.name": "python-year"})

# setup OTLP exporter
otlp_exporter = OTLPSpanExporter(
    endpoint="https://api.honeycomb.io",
    headers=(
        ("x-honeycomb-team", os.getenv("HONEYCOMB_API_KEY", "")),
        ("x-honeycomb-dataset", os.getenv("HONEYCOMB_DATASET", "")),
    ),
)

# setup trace provider
provider = TracerProvider(resource=resource)
provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

app = FastAPI()
FastAPIInstrumentor.instrument_app(app)


@app.get("/", response_class=HTMLResponse)
def home():
    return "service: <a href='/year'>/year</a>"


@app.get("/year")
async def year():
    span = trace.get_current_span()
    span.set_attribute("foo", "bar")

    await do_some_work()

    result = await get_year()
    return {
        "language": "Python",
        "year": result,
        "generated": datetime.datetime.now().isoformat(),
    }


async def do_some_work():
    with tracer.start_as_current_span("some-work") as span:
        span.set_attribute("otel", "rocks")
        rnd = get_random_int(250)
        await asyncio.sleep(rnd / 1000)


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

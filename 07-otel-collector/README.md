## Docker Quickstart

```
docker pull ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.92.0
```

Replace <YOUR-API-KEY> with your Honeycomb API key and run the docker container:

```
# Set the endpoint to the local collector
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Run the collector docker container
docker run \
    -v $(pwd)/otel-config.yaml:/etc/otelcol-contrib/config.yaml \
    --env HONEYCOMB_API_KEY=<YOUR-API-KEY> \
    -p 4317:4317 \
    -p 4318:4318 \
    -p 13133:13133 \
    ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.92.0
```

You can now run the example application and send the data to Honeycomb via your local collector.

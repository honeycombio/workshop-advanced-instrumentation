#!/bin/bash

print_usage() {
  echo "setup-env.sh <api key>"
}

if [[ -z "$1" ]]; then
  print_usage
  exit 1
fi

echo "setting up environment..."
echo "HONEYCOMB_API_KEY=$1" > .env
echo "OTEL_EXPORTER_OTLP_HEADERS=\"x-honeycomb-team=$1\"" >> .env
echo "OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io:443" >> .env
echo "OTEL_METRICS_EXPORTER=\"none\"" >> .env
echo "OTEL_LOGS_EXPORTER=\"otlp\"" >> .env
echo "done"

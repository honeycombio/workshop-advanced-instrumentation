#!/bin/bash

# get the path of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

module_step=$(basename "$PWD")
OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io:443"
OTEL_RESOURCE_ATTRIBUTES="workshop-step=${module_step}"
OTEL_SERVICE_NAME="$1"
OTEL_METRICS_EXPORTER="none"
OTEL_LOGS_EXPORTER="otlp"
OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"

run_frontend() {
  export $(cat "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
  export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER
  export OTEL_EXPORTER_OTLP_PROTOCOL=$OTEL_EXPORTER_OTLP_PROTOCOL

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    npm run start &
  else
    npm run start
  fi
}

run_frontend
#!/bin/bash

# get the path of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

module_step=$(basename "$PWD")
OTEL_RESOURCE_ATTRIBUTES="workshop-step=${module_step}"
OTEL_SERVICE_NAME="$1"
OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"

run_frontend() {
  export $(envsubst < "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_EXPORTER_OTLP_PROTOCOL=$OTEL_EXPORTER_OTLP_PROTOCOL

  # Replace the apiKey in the observability.tsx file
  TSX_FILE="$SCRIPT_DIR/components/observability.tsx"
  OS_PLATFORM=$(uname)
  if [[ -f "$TSX_FILE" ]]; then
    if [[ "$OS_PLATFORM" == "Darwin" ]]; then
      sed -i '' "s/apiKey: '[^']*',/apiKey: '$HONEYCOMB_API_KEY',/" "$TSX_FILE"
    else
      sed -i "s/apiKey: '[^']*',/apiKey: '$HONEYCOMB_API_KEY',/" "$TSX_FILE"
    fi
  fi

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    npm run start &
  else
    npm run start
  fi
}

run_frontend
#!/bin/bash

# get the path of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

module_step=$(basename "$PWD")
OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io:443"
OTEL_RESOURCE_ATTRIBUTES="workshop-step=${module_step}"
OTEL_SERVICE_NAME="$1"
OTEL_METRICS_EXPORTER="none"
OTEL_LOGS_EXPORTER="none"

run_go() {
  cd "$SCRIPT_DIR/$1" || exit
  export $(cat "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
  export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
  export OTEL_EXPORTER_OTLP_HEADERS=$OTEL_EXPORTER_OTLP_HEADERS
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER

  go build -o "bin/$1" main

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    "bin/$1" &
  else
    "bin/$1"
  fi
}

run_java() {

  cd "$SCRIPT_DIR/$1" || exit
  export $(cat "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
  export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
  export OTEL_EXPORTER_OTLP_HEADERS=$OTEL_EXPORTER_OTLP_HEADERS
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER
  gradle bootJar

  # Run your app with the auto-instrumentation agent as a sidecar
  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/opentelemetry-javaagent.jar -jar "build/libs/$1.jar" &
  else
    java -javaagent:../../lib/opentelemetry-javaagent.jar -jar "build/libs/$1.jar"
  fi
}

run_node() {
  cd "$SCRIPT_DIR/$1" || exit
  export $(cat "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
  export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
  export OTEL_EXPORTER_OTLP_HEADERS=$OTEL_EXPORTER_OTLP_HEADERS
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node --require @opentelemetry/auto-instrumentations-node/register "$1.js" &
  else
    node --require @opentelemetry/auto-instrumentations-node/register "$1.js"
  fi
}

run_python() {
  cd "$SCRIPT_DIR/$1" || exit
  export $(cat "$SCRIPT_DIR/../.env" | grep "^[^#;]" | xargs)
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
  export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
  export OTEL_EXPORTER_OTLP_HEADERS=$OTEL_EXPORTER_OTLP_HEADERS
  export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
  export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
  export OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER  # export OTEL_LOGS_EXPORTER=console

  pip install -r requirements.txt
  opentelemetry-bootstrap -a install

  port=6001
  if [[ "$1" == "python-name" ]]; then
    port=6002
  fi

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    opentelemetry-instrument uvicorn "$1:app" --host 0.0.0.0 --port $port &
  else
    opentelemetry-instrument uvicorn "$1:app" --host 0.0.0.0 --port $port
  fi
}

case $1 in

"go-year" | "go-name")
  echo "$1"
  run_go "$@"
  ;;

"java-year" | "java-name")
  echo "$1"
  run_java "$@"
  ;;

"node-year" | "node-name")
  echo "$1"
  run_node "$@"
  ;;

"python-year" | "python-name")
  echo "$1"
  run_python "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
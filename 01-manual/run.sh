#!/bin/bash

export OTEL_METRICS_EXPORTER="none"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io:443"
export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}"
export OTEL_SERVICE_NAME="$1"

go_year() {
  cd go-year || exit

  go build -o bin/go-year main.go

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    bin/go-year &
  else
    bin/go-year
  fi
}

java_year() {

  cd java-year || exit

  gradle bootJar

  # Run your app with the auto-instrumentation agent as a sidecar
  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/opentelemetry-javaagent.jar -jar build/libs/java-year.jar &
  else
    java -javaagent:../../lib/opentelemetry-javaagent.jar -jar build/libs/java-year.jar
  fi
}

node_year() {
  cd node-year || exit

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node -r ./tracing.js node-year.js &
  else
    node -r ./tracing.js node-year.js
  fi
}

python_year() {
  cd python-year || exit

  pip install -r requirements.txt

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    opentelemetry-instrument uvicorn python-year:app --host 0.0.0.0 --port 6001 &
  else
    opentelemetry-instrument uvicorn python-year:app --host 0.0.0.0 --port 6001
  fi
}

case $1 in

"go-year")
  echo "go-year"
  go_year "$@"
  ;;

"java-year")
  echo "java-year"
  java_year "$@"
  ;;

"node-year")
  echo "node-year"
  node_year "$@"
  ;;

"python-year")
  echo "python-year"
  python_year "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
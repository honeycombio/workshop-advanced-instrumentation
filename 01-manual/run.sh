#!/bin/bash

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

  export OTEL_METRICS_EXPORTER="none"
  export OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io"
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY},x-honeycomb-dataset=${HONEYCOMB_DATASET:-workshop}"
  export OTEL_SERVICE_NAME="java-year"

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
    node -r ./tracing.js  node-year.js
  fi
}

python_year() {
  cd python-year || exit

  pip install -r requirements.txt

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    uvicorn python-year:app --host 0.0.0.0 --port 6001 &
  else
    uvicorn python-year:app --host 0.0.0.0 --port 6001
  fi
}

elixir_year() {
  cd elixir_year || exit

  mix deps.get

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    echo "Cannot start Elixir Phoenix server in detached mode. Use without -b option."
  else
    mix phx.server
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

"elixir-year")
  echo "elixir-year"
  elixir_year "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
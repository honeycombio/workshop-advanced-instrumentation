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
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY},x-honeycomb-dataset=${HONEYCOMB_DATASET}"
  export OTEL_RESOURCE_ATTRIBUTES="service.name=java-year"

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/opentelemetry-javaagent-all.jar -jar build/libs/java-year.jar &
  else
    java -javaagent:../../lib/opentelemetry-javaagent-all.jar -jar build/libs/java-year.jar
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

*)
  echo "bad option"
  ;;
esac
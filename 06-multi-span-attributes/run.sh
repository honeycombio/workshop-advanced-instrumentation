#!/bin/bash

go_name() {
  cd go-name || exit

  go build -o bin/go-name main.go

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    bin/go-name &
  else
    bin/go-name
  fi
}

go_year() {
  export OTEL_METRICS_EXPORTER="none"
  export OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io:443"
  export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY},x-honeycomb-dataset=${HONEYCOMB_DATASET:-workshop}"
  export OTEL_SERVICE_NAME="go-year"

  cd go-year || exit

  go build -o bin/go-year main.go

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    bin/go-year &
  else
    bin/go-year
  fi
}

java_name() {

  cd java-name || exit

  gradle bootJar

  export SERVICE_NAME="java-name"

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent.jar -jar build/libs/java-name.jar &
  else
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent.jar -jar build/libs/java-name.jar
  fi
}

java_year() {

  cd java-year || exit

  gradle bootJar

  export SERVICE_NAME="java-year"

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent.jar -jar build/libs/java-year.jar &
  else
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent.jar -jar build/libs/java-year.jar
  fi
}

case $1 in

"go-name")
  echo "go-name"
  go_name "$@"
  ;;

"go-year")
  echo "go-year"
  go_year "$@"
  ;;

"java-name")
  echo "java-name"
  java_name "$@"
  ;;

"java-year")
  echo "java-year"
  java_year "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
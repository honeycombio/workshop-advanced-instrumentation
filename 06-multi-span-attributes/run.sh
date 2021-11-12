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
  cd go-year || exit

  go build -o bin/go-year main.go

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    bin/go-year &
  else
    bin/go-year
  fi
}

java_name() {

  JAR_NAME=$(basename $(pwd))-java-name.jar

  cd java-name || exit

  gradle bootJar

  export OTEL_METRICS_EXPORTER="none"
  export SERVICE_NAME="java-name"

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent-0.6.1-all.jar -jar build/libs/$JAR_NAME &
  else
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent-0.6.1-all.jar -jar build/libs/$JAR_NAME
  fi
}

java_year() {

  JAR_NAME=$(basename $(pwd))-java-year.jar

  cd java-year || exit

  gradle bootJar

  export SERVICE_NAME="java-year"

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent-0.6.1-all.jar -jar build/libs/$JAR_NAME &
  else
    java -javaagent:../../lib/honeycomb-opentelemetry-javaagent-0.6.1-all.jar -jar build/libs/$JAR_NAME
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
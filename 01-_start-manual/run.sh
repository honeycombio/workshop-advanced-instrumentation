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

  JAR_NAME=$(basename $(pwd))-java-year.jar

  cd java-year || exit

  gradle bootJar

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -jar build/libs/$JAR_NAME &
  else
    java -jar build/libs/$JAR_NAME
  fi
}
node_year() {
  cd node-year || exit

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node node-year.js &
  else
    node node-year.js
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
*)
  echo "bad option"
  ;;
esac
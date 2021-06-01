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

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -jar build/libs/java-year.jar &
  else
    java -jar build/libs/java-year.jar
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
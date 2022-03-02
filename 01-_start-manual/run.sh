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
node_year() {
  cd node-year || exit

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node node-year.js &
  else
    node node-year.js
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
#!/bin/bash

run_go() {
  cd "$1" || exit

  go build -o "bin/$1" main

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    "bin/$1" &
  else
    "bin/$1"
  fi
}

run_java() {

  cd "$1" || exit

  gradle bootJar

  # Run your app with the auto-instrumentation agent as a sidecar
  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -jar "build/libs/$1.jar" &
  else
    java -jar "build/libs/$1.jar"
  fi
}

run_node() {
  cd "$1" || exit

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node "$1.js" &
  else
    node "$1.js"
  fi
}

run_python() {
  cd "$1" || exit

  pip install -r requirements.txt
  opentelemetry-bootstrap -a install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    uvicorn "$1:app" --host 0.0.0.0 --port 6001 &
  else
    uvicorn "$1:app" --host 0.0.0.0 --port 6001
  fi
}

case $1 in

"go-year")
  echo "$1"
  run_go "$@"
  ;;

"java-year")
  echo "$1"
  run_java "$@"
  ;;

"node-year")
  echo "$1"
  run_node "$@"
  ;;

"python-year")
  echo "$1"
  run_python "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
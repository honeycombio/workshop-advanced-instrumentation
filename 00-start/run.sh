#!/bin/bash

# get the path of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

module_step=$(basename "$PWD")

run_go() {
  cd "$SCRIPT_DIR/$1" || exit

  go build -o "bin/$1" main

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    "bin/$1" &
  else
    "bin/$1"
  fi
}

run_java() {

  cd "$SCRIPT_DIR/$1" || exit
  gradle bootJar

  # Run your app with the auto-instrumentation agent as a sidecar
  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    java -jar "build/libs/$1.jar" &
  else
    java -jar "build/libs/$1.jar"
  fi
}

run_node() {
  cd "$SCRIPT_DIR/$1" || exit

  npm install

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    node "$1.js" &
  else
    node "$1.js"
  fi
}

run_python() {
  cd "$SCRIPT_DIR/$1" || exit
  if [[ -d "$SCRIPT_DIR/../.venv" ]]; then
    export PATH="$SCRIPT_DIR/../.venv/bin:$PATH"
  fi

  pip install -r requirements.txt

  port=6001
  if [[ "$1" == "python-name" ]]; then
    port=6002
  fi

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    uvicorn "$1:app" --host 0.0.0.0 --port $port &
  else
    uvicorn "$1:app" --host 0.0.0.0 --port $port
  fi
}

run_dotnet() {
  cd "$SCRIPT_DIR/$1" || exit

  dotnet build -o bin -nologo -v q

  if [[ -n "$2" ]] && [[ "$2" == "-b" ]]; then
    dotnet bin/"$1".dll &
  else
    dotnet bin/"$1".dll
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

"dotnet-year" | "dotnet-name")
  echo "$1"
  run_dotnet "$@"
  ;;

*)
  echo "bad option"
  ;;
esac
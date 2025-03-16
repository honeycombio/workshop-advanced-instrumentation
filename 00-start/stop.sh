#!/bin/bash

case "$1" in

"go-year" | "go-name" | "java-year" | "java-name" | "node-year" | "node-name")
  pkill -f "$1"
  ;;

"")
  echo "stopping all"
  pkill -f go-year
  pkill -f go-name
  pkill -f java-year
  pkill -f java-name
  pkill -f node-year
  pkill -f node-name
  ;;

*)
  echo "bad option"
  ;;

esac
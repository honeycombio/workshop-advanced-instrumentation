#!/bin/bash

print_usage() {
  echo "setup-env.sh <api key>"
}

if [[ -z "$1" ]]; then
  print_usage
  exit 1
fi

echo "setting up environment..."
echo "HONEYCOMB_API_KEY=$1" > .env
echo "done"

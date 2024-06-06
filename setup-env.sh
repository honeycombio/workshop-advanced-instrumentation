#!/bin/bash

print_usage() {
  echo "setup-env.sh <api key>"
}

if [[ -z "$1" ]]; then
  print_usage
  exit 1
fi

echo "setting up environment"
export HONEYCOMB_API_KEY="$1"

echo "persisting to user profile"

case $SHELL in
*/zsh)
  cat >> ~/.zshrc <<EOL
export HONEYCOMB_API_KEY="$1"
EOL
   ;;
*/bash)
  cat >> ~/.bashrc <<EOL
export HONEYCOMB_API_KEY="$1"
EOL
   ;;
*)
  cat >> ~/.profile <<EOL
export HONEYCOMB_API_KEY="$1"
EOL
esac

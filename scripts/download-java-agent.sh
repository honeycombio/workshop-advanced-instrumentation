#!/usr/bin/env bash
# Download the latest OpenTelemetry Java agent JAR into the workshop lib/ directory.
# Required for running Java services (run.sh java-year, java-name) and the 16-message-queue example.
# See: https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
AGENT_JAR="$LIB_DIR/opentelemetry-javaagent.jar"

mkdir -p "$LIB_DIR"

# Use a known-good version that matches OpenTelemetry Java SDK 1.59 (see workshop build.gradle BOM)
VERSION="${OTEL_JAVAAGENT_VERSION:-2.25.0}"
DOWNLOAD_URL="https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${VERSION}/opentelemetry-javaagent.jar"

echo "Downloading OpenTelemetry Java agent v${VERSION} to $AGENT_JAR"
if command -v curl &>/dev/null; then
  curl -sSL -o "$AGENT_JAR" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
  wget -q -O "$AGENT_JAR" "$DOWNLOAD_URL"
else
  echo "Error: need curl or wget to download the agent" >&2
  exit 1
fi

echo "Done. Use with: java -javaagent:$AGENT_JAR -jar your-app.jar"

#!/bin/bash

export JAVA_TOOL_OPTIONS="-javaagent:../lib/honeycomb-opentelemetry-javaagent.jar"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="none"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io"
export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=$HONEYCOMB_API_KEY"
export SERVICE_NAME="kafka-producer"

# Compile the project
mvn clean compile

# Run the Kafka producer
mvn exec:java -Dexec.mainClass="com.example.kafka.BatchProducerWithHeader" 
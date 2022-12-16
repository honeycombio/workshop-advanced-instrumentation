#!/bin/bash
wget -O "otelcol.tar.gz" "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.67.0/otelcol-contrib_0.67.0_linux_amd64.tar.gz" 
gzip -d otelcol.tar.gz
tar -xvf otelcol.tar
chmod +x otelcol-contrib
#!/bin/bash
source /usr/local/sdkman/bin/sdkman-init.sh 2>/dev/null || true
JAVA_17=$(find /usr/local/sdkman/candidates/java -maxdepth 1 -type d -name "17.*" 2>/dev/null | head -1)
if [ -n "$JAVA_17" ]; then
    export JAVA_HOME="$JAVA_17"
    echo "export JAVA_HOME=\"$JAVA_17\"" >> ~/.bashrc
    echo "Fixed! JAVA_HOME is now: $JAVA_17"
    java -version
else
    echo "Java 17 not found. Available versions:"
    ls -la /usr/local/sdkman/candidates/java/ 2>/dev/null || echo "SDKMAN not found"
fi

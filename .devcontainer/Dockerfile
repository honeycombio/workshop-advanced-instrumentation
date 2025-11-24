FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install required system packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    gettext \
    build-essential \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/python/install.sh | bash -s -- --version 3.11

# Install Node.js 20
RUN curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/node/install.sh | bash -s -- --version 20

# Install Java 17 explicitly via SDKMAN (not using the feature which installs Java 25)
RUN curl -sSL "https://get.sdkman.io" | bash && \
    bash -c 'export SDKMAN_DIR="/root/.sdkman" && \
    source "$SDKMAN_DIR/bin/sdkman-init.sh" && \
    export SDKMAN_NONINTERACTIVE=true && \
    sdk install java 17.0.12-tem && \
    sdk install gradle 8.11 && \
    sdk default java 17.0.12-tem' && \
    mv /root/.sdkman /usr/local/sdkman && \
    chown -R vscode:vscode /usr/local/sdkman && \
    JAVA_17_ACTUAL=$(find /usr/local/sdkman/candidates/java -maxdepth 1 -type d -name "17.*" | head -1) && \
    if [ -n "$JAVA_17_ACTUAL" ] && [ -d "$JAVA_17_ACTUAL" ]; then \
        ln -sf "$JAVA_17_ACTUAL" /usr/local/sdkman/candidates/java/current && \
        ln -sf "$JAVA_17_ACTUAL/bin/java" /usr/local/bin/java && \
        ln -sf "$JAVA_17_ACTUAL/bin/javac" /usr/local/bin/javac && \
        echo "export JAVA_HOME=\"$JAVA_17_ACTUAL\"" >> /etc/bash.bashrc; \
    fi && \
    GRADLE_ACTUAL=$(find /usr/local/sdkman/candidates/gradle -maxdepth 1 -type d -name "8.*" | head -1) && \
    if [ -n "$GRADLE_ACTUAL" ] && [ -d "$GRADLE_ACTUAL" ]; then \
        ln -sf "$GRADLE_ACTUAL" /usr/local/sdkman/candidates/gradle/current && \
        ln -sf "$GRADLE_ACTUAL/bin/gradle" /usr/local/bin/gradle; \
    fi && \
    echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> /etc/bash.bashrc && \
    echo "export SDKMAN_DIR=\"/usr/local/sdkman\"" >> /etc/bash.bashrc && \
    echo ". \"\$SDKMAN_DIR/bin/sdkman-init.sh\" 2>/dev/null || true" >> /etc/bash.bashrc

# Install Go 1.21
RUN export GOLANG_VERSION=1.21.13 && \
    export GOARCH=$(dpkg --print-architecture) && \
    if [ "$GOARCH" = "amd64" ]; then export GOARCH="amd64"; \
    elif [ "$GOARCH" = "arm64" ]; then export GOARCH="arm64"; \
    else export GOARCH="amd64"; fi && \
    curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-${GOARCH}.tar.gz" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt && \
    echo "export GOPATH=/home/vscode/go" >> /etc/bash.bashrc && \
    echo "export PATH=\"/usr/local/go/bin:\$GOPATH/bin:\$PATH\"" >> /etc/bash.bashrc && \
    mkdir -p /home/vscode/go && \
    chown -R vscode:vscode /home/vscode/go

# Create global run.sh wrapper that finds the nearest run.sh script
RUN printf '#!/bin/bash\nSCRIPT_DIR="$(pwd)"\nwhile [ "$SCRIPT_DIR" != "/" ]; do\n    if [ -f "$SCRIPT_DIR/run.sh" ]; then\n        exec "$SCRIPT_DIR/run.sh" "$@"\n    fi\n    SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"\ndone\necho "Error: run.sh not found in any parent directory" >&2\nexit 1\n' > /usr/local/bin/run.sh && chmod +x /usr/local/bin/run.sh

WORKDIR /workspace
USER vscode


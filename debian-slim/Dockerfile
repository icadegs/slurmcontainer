FROM debian:12-slim

# Install basic tools
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    nano \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["/bin/bash"]


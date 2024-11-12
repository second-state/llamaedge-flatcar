FROM ubuntu:latest
ARG BACKEND=llama

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y bash curl git && \
    rm -rf /var/lib/apt/lists/*

# Install WasmEdge
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s -- -v 0.14.1

# Install WasiNN whisper plugin if need and download wasm application
RUN if [ "$BACKEND" = "whisper" ]; then \
        curl -LO https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-plugin-wasi_nn-whisper-0.14.1-ubuntu20.04_x86_64.tar.gz && \
        tar -xzf WasmEdge-plugin-wasi_nn-whisper-0.14.1-ubuntu20.04_x86_64.tar.gz -C $HOME/.wasmedge/plugin && \
        rm WasmEdge-plugin-wasi_nn-whisper-0.14.1-ubuntu20.04_x86_64.tar.gz && \
        curl -LO https://github.com/LlamaEdge/whisper-api-server/releases/download/0.3.0/whisper-api-server.wasm; \
    elif [ "$BACKEND" = "llama" ]; then \
        curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm; \
    fi

ENV PATH="/root/.wasmedge/bin:${PATH}"

# Set default shell to bash
CMD ["/bin/bash"]
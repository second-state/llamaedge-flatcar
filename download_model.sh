#!/bin/bash

# Download Llama demo model
echo "Downloading Llama 3.2 Instruct model..."
curl -LO https://huggingface.co/second-state/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q2_K.gguf

# Download Nomic embedding model
echo "Downloading Nomic embedding model..."
curl -LO https://huggingface.co/gaianet/Nomic-embed-text-v1.5-Embedding-GGUF/resolve/main/nomic-embed-text-v1.5.f16.gguf

# Download Whisper demo model
echo "Downloading Whisper demo model..."
curl -LO https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin

echo "All models have been downloaded successfully!"
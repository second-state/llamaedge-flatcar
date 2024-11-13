# llamaedge-flatcar
This is a demo repository intended to demonstrate how to run LlamaEdge workload inside Flatcar.

**And you need to clone this repository as your working directory.**

## Run flatcar on QEMU

If you are deploying Flatcar directly on your machine, you can skip this section.


Download flatcar image from stable channel
```bash
cd llamaedge-flatcar

wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu.sh
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu.sh.sig
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.sig
gpg --verify flatcar_production_qemu.sh.sig
gpg --verify flatcar_production_qemu_image.img.sig
```

Launch flatcar on QEMU

```bash
./flatcar_production_qemu.sh -M 8G -nographic
```

Mount our working directory into the Flatcar VM
```bash
mkdir -p $(pwd)/llamaedge-flatcar
sudo mount -t 9p -o trans=virtio llamaedge-flatcar $(pwd)/llamaedge-flatcar
sudo chmod a+w llamaedge-flatcar
```

> You can use the command `ps aux | grep '[q]emu' | awk '{print $2}' | xargs kill` to close QEMU vm."

## Demo with our services

Download demo models
```bash
cd llamaedge-flatcar
./download_model.sh
```

### Llama service

Launch service
```bash
docker run -d --rm \
  -v $(pwd):/models \
  -p 9091:8080 \
  wasmedge/llamaedge-flatcar:llama-service \
  wasmedge --dir .:. --nn-preload default:GGML:AUTO:/models/Llama-3.2-1B-Instruct-Q2_K.gguf --nn-preload embedding:GGML:AUTO:/models/nomic-embed-text-v1.5.f16.gguf llama-api-server.wasm --model-alias default,embedding --model-name llama-3-1b-chat,nomic-embed --prompt-template llama-3-chat,embedding --batch-size 128,8192 --ctx-size 8192,8192


// Originally planned to use docker compose up -d llama-service
// But docker-compose is not supported inside Flatcar
```

Demo
```bash
curl -X POST http://0.0.0.0:9091/v1/chat/completions -H 'accept:application/json' -H 'Content-Type: application/json' -d '{"messages":[{"role":"system", "content":"You are a helpful AI assistant"}, {"role":"user", "content":"What is the capital of France?"}], "model":"llama-3-1B-chat"}'
```

Output
```bash
{"id":"chatcmpl-2d919b62-b337-42dd-b3f6-a5810defeadd","object":"chat.completion","created":1731395661,"model":"llama-3-1b-chat","choices":[{"index":0,"message":{"content":"Paris is the capital of France, it's a country located in Western Europe, and it's also the largest city with over 1.8 million people.","role":"assistant"},"finish_reason":"stop","logprobs":null}],"usage":{"prompt_tokens":28,"completion_tokens":34,"total_tokens":62}}%
```

### Whisper service

Launch service
```bash
docker run -d --rm \
  -v $(pwd):/models \
  -p 9090:8080 \
  wasmedge/llamaedge-flatcar:whisper-service \
  wasmedge --dir .:. whisper-api-server.wasm -m /models/ggml-medium.bin


// Originally planned to use docker compose up -d whisper-service
// But docker-compose is not supported inside Flatcar
```

Demo
```bash
curl -LO https://github.com/LlamaEdge/whisper-api-server/raw/main/data/test.wav
curl --location 'http://localhost:9090/v1/audio/transcriptions' \
  --header 'Content-Type: multipart/form-data' \
  --form 'file=@"test.wav"'
```

Output
```bash
{"text":"[00:00:00.000 --> 00:00:04.000]  This is a test record for Whisper.cpp"}%
```

## Future work

In the next phase, we will consider shipping our runtime as the default package or using the Flatcar SDK to build custom Flatcar images with WasmEdge built-in, in order to reduce the overhead that might be caused by Docker.

https://github.com/flatcar/Flatcar/blob/main/adding-new-packages.md
https://www.flatcar.org/docs/latest/reference/developer-guides/sdk-modifying-flatcar/

#!/bin/bash

docker run --rm --gpus all --mount "type=bind,source=$PWD,target=/app" -w /app/scripts --entrypoint /bin/bash vmaf -c "
./parallelizer.sh 2 5 ./vmaf_gpu.sh /app/media/ref/tears_of_steel_1080p.webm /app/media/480p/crf_25/distorted.mkv 20
"

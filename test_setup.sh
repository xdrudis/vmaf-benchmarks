#!/bin/bash


docker run --rm --gpus all --mount "type=bind,source=$PWD,target=/app" --entrypoint /bin/bash vmaf -x -c "
/app/scripts/vmaf_cpu.sh /app/media/ref/tears_of_steel_1080p.webm /app/media/480p/crf_25/distorted.mkv 20
/app/scripts/vmaf_gpu.sh /app/media/ref/tears_of_steel_1080p.webm /app/media/480p/crf_25/distorted.mkv 20
"

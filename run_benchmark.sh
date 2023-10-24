#!/bin/bash


docker run --rm --gpus all --mount "type=bind,source=$PWD,target=/app" -w /app/scripts --entrypoint /bin/bash vmaf -c '
  for sampling in 1 2 5 10 15 25 ; do
    ./parallelizer.sh 1 1 ./vmaf_cpu.sh /app/media/ref/tears_of_steel_1080p.webm /app/media/480p/crf_25/distorted.mkv $sampling > cpu_sampling_$sampling.csv
    ./parallelizer.sh 1 1 ./vmaf_gpu.sh /app/media/ref/tears_of_steel_1080p.webm /app/media/480p/crf_25/distorted.mkv $sampling > gpu_sampling_$sampling.csv
 done
'

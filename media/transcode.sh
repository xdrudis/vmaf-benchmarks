#!/bin/bash

# https://mirrors.dotsrc.org/blender/blender-demo/movies/ToS/tears_of_steel_1080p.webm
ref=./ref/tears_of_steel_1080p.webm
for crf in 21 23 25 27 ; do
	for res in 1080 720 480 ; do
		mkdir -p ${res}p/crf_$crf
		ffmpeg -v error -y -i $ref -preset fast -crf $crf -vf scale=$res:-2 ${res}p/crf_$crf/distorted.mkv
	done
done


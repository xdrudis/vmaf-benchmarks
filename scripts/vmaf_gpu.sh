#!/bin/bash

# Usage: vmaf_gpu.sh {reference.mp4} {distorted.mp4}


[ $# -lt 2 ] && echo "Usage: $0 {reference.mp4} {distorted.mp4} [subsampling]" && exit 1
[ ! -r "$1" ] && echo "Can't read reference file '$1'" && exit 1
[ ! -r "$2" ] && echo "Can't read distorted file '$2'" && exit 1
subsample=${3:-1} # by default no subsampling

function ffprobeStream {
  ffprobe -hide_banner -v error \
	  -select_streams V:0 \
	  -of 'default=nokey=1:noprint_wrappers=1' \
	  -show_entries "stream=$1" \
	  "$2"
}

reference="$1"
width=$(ffprobeStream 'width' "$reference")
height=$(ffprobeStream 'height' "$reference")

distorted="$2"

/usr/bin/time -f "%e %U %S" ffmpeg -hide_banner -v error -nostats \
	-init_hw_device cuda:0,primary_ctx=1 \
	-i "$distorted" -i "$reference" \
	-threads 12 \
	-map 0:v -map 1:v \
	-filter_complex \
	  "[0:v]format=yuv420p,hwupload_cuda,scale_cuda=w=$width:h=$height:interp_algo=bicubic,setpts=PTS-STARTPTS[dist],
[1:v]format=yuv420p,hwupload_cuda,setpts=PTS-STARTPTS[ref],
[ref][dist]libvmaf_cuda=model='path=/usr/local/share/model/vmaf_v0.6.1neg.json':n_subsample=$subsample:log_fmt=json:log_path=/dev/stdout:pool=harmonic_mean" \
	-f null - | jq '.pooled_metrics.vmaf.harmonic_mean'

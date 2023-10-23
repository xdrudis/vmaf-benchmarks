#!/bin/bash

# Usage: vmaf_cpu.sh {reference.mp4} {distorted.mp4}


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
wh=$(ffprobeStream 'width,height' "$reference")
reference_res=$(echo $wh | sed 's/ /x/')
ref_fps=$(ffprobeStream r_frame_rate "$reference")

distorted="$2"
dist_fps=$(ffprobeStream r_frame_rate "$distorted")

if [ $ref_fps != $dist_fps ] ; then
	ref_fps=$(ffprobeStream avg_frame_rate "$reference")
	dist_fps=$(ffprobeStream avg_frame_rate "$distorted")
fi

/usr/bin/time -f "%e %U %S" ffmpeg -hide_banner -v error -nostats -i "$distorted" -i "$reference" \
	-map 0:v -map 1:v \
	-threads 12 \
	-filter_complex \
	  "[0:v]fps=fps=$dist_fps,scale=$reference_res:flags=bicubic,setpts=PTS-STARTPTS[refrence];
[1:v]fps=fps=$ref_fps,setpts=PTS-STARTPTS[distorted],
[refrence][distorted]libvmaf=model='path=/usr/local/share/model/vmaf_v0.6.1neg.json':n_subsample=$subsample:n_threads=12:log_fmt=json:log_path=/dev/stdout:pool=harmonic_mean" -f null - | 
  jq '.pooled_metrics.vmaf.harmonic_mean'


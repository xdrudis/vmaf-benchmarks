#!/bin/bash

# ./parallelizer.sh concurrent_executions total_executions command

# Validate input arguments
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <concurrent_executions> <total_executions> <command>"
  exit 1
fi

concurrent=$1
shift
total=$1
shift
command_to_run="$@"

# Function to run script and capture stdout and stderr separately
run_script() {
  # Create unique named pipes (FIFOs) for stdout and stderr
  local tmp_stdout=$(mktemp)
  local tmp_stderr=$(mktemp)

  # Run your script and redirect stdout and stderr to named pipes
  eval $@ > "$tmp_stdout" 2> "$tmp_stderr"

  # Read from named pipes into variables
  local vmaf_output=$(cat "$tmp_stdout")
  local time_output=$(cat "$tmp_stderr")

  # Print stdout and stderr on the same line
  echo $vmaf_output $time_output | sed 's/  */,/g'
  
  # Clean up: remove the named pipes
  rm "$tmp_stdout" "$tmp_stderr"
}

# Export the function to make it available to GNU parallel
export -f run_script
parallel -j $concurrent run_script $command_to_run ::: $(seq 1 $total)


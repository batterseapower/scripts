#!/bin/sh

# sudo runs the backup as root
# --eahfs enables HFS+ mode
# -a turns on archive mode (recursive copy + retain attributes)
# -x don't cross device boundaries (ignore mounted volumes)
# -S handle sparse files efficiently
# --showtogo shows the number of files left to process
# --delete deletes any files that have been deleted locally
# $* expands to any extra command line options you may give

for directory in $*; do
  echo "Copying $directory";
  /usr/bin/rsync -E -a -x -S --delete "/Volumes/Data-1/$directory" "./$directory";
done
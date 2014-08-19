#!/bin/bash 
function die() { echo "Error in $0: $1"; exit 1; }
BASE_IMAGES=$(btrfs subvolume list -p /srv/ | awk '{print $NF}' | grep 'base-') || die "Failed to get images from /srv"

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@      Images present:                       @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo 

for IMAGE in ${BASE_IMAGES[@]} 
do
    echo $( basename "$IMAGE" )
done

echo 

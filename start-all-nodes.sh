#!/bin/bash
function die() { echo "Error in $0: $1"; exit 1; }

TYPES="wheezy squeeze64 squeeze32"
for TYPE in $TYPES
do
	/root/bin/tools/new-agentnode.sh $TYPE || die "Failed to spawn node" &
done

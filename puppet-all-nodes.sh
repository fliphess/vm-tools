#!/bin/bash
function die() { echo "Error in $0: $1"; exit 1; }

HOSTS=( 'agent1.c1' 'agent2.c1' 'agent3.c1' )

for HOST in ${HOSTS[@]}
do
	ssh root@$HOST "puppet agent -t" &
done

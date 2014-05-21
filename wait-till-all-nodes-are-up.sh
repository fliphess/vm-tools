#!/bin/bash

HOSTS="agent1.c1 agent2.c1 agent3.c1"


function testping() {
	local HOST="$1"
	ping -q -c 1 -w 1 "$HOST"  >/dev/null
	if [ $? -eq 0 ] ; then 
		return 0
	fi
	return 1
}

function testssh() {
	local HOST="$1"
	ssh -o 'BatchMode yes' -qq "$HOST" "exit 0"
	if [ $? -eq 0 ]; then
		return 0
	fi 
	return 1
}

function poller() {
	HOST="$1"
	if testping "$HOST" && testssh "$HOST"; then
		return 0
	fi
	return 1
}

while ! (for HOST in $HOSTS; do LAST=$HOST; poller "$HOST"; done); do 
	echo "Not all hosts are responding to ping and ssh yet!"
	echo "Last was $LAST"
	sleep 2
done

echo "ALL HOSTS UP"
exit 0



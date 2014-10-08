#!/bin/bash 
# Teh plakzor
[ -f /tmp/flippy-power ] && exit 0
touch /tmp/flippy-power

#
# Lets have some fun and startup a testing environment of a squeeze32, squeeze64 and a wheezy64 box
#
cd /root/bin/tools &&

	# Lets kill the previous, prolly running vm's
	/root/bin/tools/kill-all-running-vms.sh > /dev/null &&

	# Then let's remove all previous brfs snapshots
	/root/bin/tools/cleanup-snapshots.pl --clean &&

	# Lets bootup some test agents
	/root/bin/tools/start-all-nodes.sh &&

	# Waaaaaaaaait.......
	/root/bin/tools/wait-till-all-nodes-are-up.sh  &&

cd /build &&
	# Let's build the motherfuckah!
	tools/update-and-build.sh 

rm /tmp/flippy-power

#!/bin/bash -x
# Reuse a current snapshot as a base snapshot
function die() { echo "Error in $0: $1"; exit 1; }

VM="$1"

# Check for root
if [ "$(whoami)" != "root" ] ; then 
	die "Must run as root!"
fi

# Check for input
if [ "x${VM}" == "x" ] ; then
	die "Usage: $0 <NAME_OF_VM>"
fi

# Get snapshot 
SNAPSHOT="/srv/images/${VM}"
if [ ! -d "${SNAPSHOT}" ] ; then
	die "Snapshot $SNAPSHOT not found!" 
fi

# Get base
BASE="/srv/images/base-${VM}"
if [ ! -d "${BASE}" ] ; then 
	die "Base ${BASE} snapshot not found"
fi


echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@ Backing up BASE: $BASE                                        @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

TIMESTAMP="$(date '+%Y%m%d%H%M')"
btrfs subvolume snapshot "$BASE" "${BASE}.${TIMESTAMP}" || die "Failed to create snapshot"

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@ Removing current base base-${VM} to replace with ${VM}        @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

btrfs subvolume delete "/srv/images/base-${VM}" || die "Failed to remove current base base-${VM}"

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@ Creating new snapshot to BASE                                 @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

btrfs subvolume snapshot "/srv/images/${VM}" "/srv/images/base-${VM}" || die "Failed to set ${VM} as base-${VM}"

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@ ALL DONE                                                      @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

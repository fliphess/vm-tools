#!/bin/bash
function die() { echo "Error in $0: $1"; exit 1; }
BASE_IMAGE="$1"


# {{{ - Sanity checks 

# Check for input
if [ "${BASE_IMAGE}x" == "x" ] ; then 
	echo "Usage: $0 <base-image-name>"
	exit 1
fi

# We can't install vm's when not root
if [ "$(whoami)" != "root" ] ; then 
	echo "Run this script as root!"
	exit 1
fi

# Script should be run from containing dir so we can easily find the settings file 
if [ "$0" !=  "./restart-node.sh" ] ; then 
	echo "Please use this script as \" cd $(basename $0) && ./restart-node.sh\""
	exit 1
fi

# Source settings file 
if [ ! -f "./settings.sh" ]; then 
	echo "Settings ./settings.sh not found in $(pwd)"
	exit 1
fi

source ./settings.sh
if [ -z $VM_SETTINGS ]; then
	echo "Settings for $BASE_IMAGE not found!"
	exit 1
fi

# }}}  

# Set snapshot location
IMAGE_DIR="/srv/images"
BASE_SNAPSHOT="${IMAGE_DIR}/${BASE_IMAGE}"

MAC_ADDRESS="${VM_SETTINGS[1]}"
DEST_DIR="${IMAGE_DIR}/${VM_SETTINGS[0]}"
DEST_IMAGE="${IMAGE_DIR}/${BASE_IMAGE}/${VM_SETTINGS[2]}"

# check if running, if so stop
if virsh list --all | grep -q "${VM_SETTINGS[0]}"; 
then
	echo "Machine ${VM_SETTINGS[0]} is running! Shutting down first, then restoring to base"
	virsh destroy "${VM_SETTINGS[0]}"  ;
       	virsh undefine "${VM_SETTINGS[0]}"
	if [ "$?" != 0 ] ; then 
		die "Failed to remove server ${VM_SETTINGS[0]}! Exiting!" 
	fi
fi
	
if [ -d "$DEST_DIR" ]; then 
	echo "Removing snapshot before creating new one"
	btrfs subvolume delete "${DEST_DIR}"
	if [ "$?" != 0 ] ; then 
		die "Failed to remove snapshot $IMAGE for server ${VM_SETTINGS[0]}! Exiting!"
	fi
fi

# create snapshot 
[ ! -d "$DEST_DIR" ] || die "$IMAGE dir stil exists!"
echo "Creating new snapshot for ${VM_SETTINGS[0]} in /srv/images/${VM_SETTINGS[0]}"
cd /srv || die "Failed to cd to /srv"

btrfs subvolume snapshot "$BASE_SNAPSHOT" "$DEST_DIR" || die "Failed to create snapshot for $DEST_DIR"

# bring up new vm 
if [ ! -f "$DEST_IMAGE" ]; then 
	die "$DEST_IMAGE not found!"
fi

echo "Spawning node ${VM_SETTINGS[0]}"
virt-install --name "${VM_SETTINGS[0]}" -r 2048 --vcpus 2 --os-type linux --virt-type kvm --serial pty --serial null --disk="${DEST_IMAGE},device=disk,format=raw,bus=virtio" --network=bridge=br0,mac="$MAC" --boot hd --video default &

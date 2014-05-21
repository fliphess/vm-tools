#!/bin/bash
function die() { echo "Error in $0: $1"; exit 1; }
VM="$1"

if [ "${VM}" == "squeeze32" ]   ; then
	SRV="agent1.c1"
	MAC="00:16:3e:00:09:0a"
	BASE="base-squeeze32"
	IMAGE="image-squeeze32.img"

elif [ "${VM}" == "squeeze64" ] ; then 
	SRV="agent2.c1"
	MAC="00:16:3e:00:09:0b"
	BASE="base-squeeze64"
	IMAGE="image-squeeze64.img"

elif [ "${VM}" == "wheezy" ]    ; then
	SRV="agent3.c1"
	MAC="00:16:3e:00:09:0c"
	BASE="base-wheezy"
	IMAGE="image-wheezy.img"

else 
	die "Usage: $0 [squeeze32|squeeze64|wheezy]"
fi

# Set snapshot location
DIR="/srv/images/$SRV"
IMAGEFILE="$DIR/$IMAGE"

# check if running, if so stop
if ( virsh list --all | grep -q "$SRV" ); then
	echo "Machine $SRV is running! Shutting down first, then restoring to base"
	virsh destroy "$SRV" && virsh undefine "$SRV"
	if [ "$?" != 0 ] ; then 
		die "Failed to remove server $SRV! Exiting!" 
	fi
fi
	
if [ -d "$DIR" ]; then 
	echo "Removing snapshot before creating new one"
	btrfs subvolume delete "${DIR}"
	if [ "$?" != 0 ] ; then 
		die "Failed to remove snapshot $IMAGE for server $SRV! Exiting!"
	fi
fi

# create snapshot 
[ ! -d "$DIR" ] || die "$IMAGE dir stil exists!"
echo "Creating new snapshot for $SRV in /srv/images/$SRV"
cd /srv || die "Failed to cd to /srv"

btrfs subvolume snapshot "$BASE" "$DIR" || die "Failed to create snapshot for $DIR"

# bring up new vm 
if [ ! -f "$IMAGEFILE" ]; then 
	die "$IMAGEFILE not found!"
fi

echo "Spawning node $SRV"
virt-install --name "$SRV" -r "2048" --vcpus "2" --os-type "linux" --virt-type "kvm" --serial "pty" --serial "null" --disk="$IMAGEFILE,device=disk,format=raw,bus=virtio" --network=bridge=br0,mac="$MAC" --boot "hd" --graphics "none"

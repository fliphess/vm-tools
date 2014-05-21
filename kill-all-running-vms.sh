#!/bin/bash
function die() { echo "Error in $0: $1"; exit 1; }

RUNNING=$( virsh list --all | sed 1,2d | grep -vE 'base-|^$'  | awk '{print $2}' ) || die "Failed to get running vm's"

for VM in $RUNNING 
do
  virsh destroy "$VM" && virsh undefine "$VM" || die "Failed to kill $VM"
done

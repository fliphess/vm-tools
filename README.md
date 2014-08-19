# BTRFS VM SETUP 

Quickly rewind vm's to their original state 


## Howto:

settings.sh                - settings file to store mac adresses

list-all-base-images.sh    - list all available images 
restart-node.sh            - start a certain node by deleting the current snapshot, creating a new one from base and starting the vm.
ping-node-till-its-hot.sh  - keep pinging a node, or a group of nodes till they respond both on ssh and ping
reuse-image-as-base.sh     - backup the old base and reuse a currently used image as the new base image

kill-all-running-vms.sh    - kill all vm's that are running
cleanup-snapshots.pl       - clean all images that are not used anymore


## Example: 

```bash 
    cd /root/bin/tools/
    ./restart-node.sh base-web1.c79
    ./ping-node-till-its-hot.sh web1.c79
```




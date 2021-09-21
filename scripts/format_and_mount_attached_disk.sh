#!/bin/bash

# The disk name is coming from Terraform variables
DISK_NAME=${disk_name}

# The mount point for the disk
MOUNT_POINT=/mnt/$DISK_NAME

# Google provides a symlink to persistent disk as '/dev/disk/by-id/google-<disk_name>'
DEVICE_NAME="/dev/$(basename $(readlink /dev/disk/by-id/google-$DISK_NAME))"

# Check if the disk already has the filesystem and mounted
# This block will try to mount the disk to the given mount point in case if it has a filesystem configured but it's not mounted to mount point.
if df -aT | grep -q "$DEVICE_NAME"; then
    echo "The disk already has filesystem configured, checking the mount point"
    if df -aT | grep "$DEVICE_NAME" | awk '{print $(NF)}' | grep -q "$MOUNT_POINT"; then
        echo "The disk $DEVICE_NAME already mounted to $MOUNT_POINT, exiting"
        exit 0
    else
        echo "Looks like the mount point $MOUNT_POINT is not mounted. Trying to mount the disk $DEVICE_NAME to $MOUNT_POINT..."
        if [ ! -d "$MOUNT_POINT" ]; then
            sudo mkdir -p $MOUNT_POINT
        fi
        sudo mount -o discard,defaults $DEVICE_NAME $MOUNT_POINT
        if [[ $? -eq 0 ]]; then
            echo "Succesfully mounted the disk $DEVICE_NAME to mount point $MOUNT_POINT"
            exit 0
        else
            echo "Failed to mount the disk $DEVICE_NAME to mount point $MOUNT_POINT"
            exit 1
        fi
    fi
else
    # Create a filesystem on the disk and mount it if it doesn't have a filesystem configured.
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DEVICE_NAME
    sudo mkdir -p $MOUNT_POINT
    sudo mount -o discard,defaults $DEVICE_NAME $MOUNT_POINT

    # Add fstab entry
    echo UUID=$(sudo blkid -s UUID -o value $DEVICE_NAME) $MOUNT_POINT ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
fi

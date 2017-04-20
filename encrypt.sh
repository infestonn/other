#!/bin/sh
#Encrypts etire disk with cryptsetup and copies new OS from another block device.
#Run from System Rescue CD


INTERFACE=`ifconfig | grep -i "mtu 1500" | awk '{print $1}' | sed 's/://g'`
DISK_A='sda'
DISK_B='sdb1'

echo -n 'Enter block device name to encrypt. Default "sda"[ENTER]: '
read INPUT
if [ -z ${INPUT} ]; then
        continue
else
        DISK_A=${INPUT}
fi
echo -n 'Enter partition name with installed OS. Default "sdb1"[ENTER]: '
read INPUT
if [ -z ${INPUT} ]; then
        continue
else
        DISK_B=${INPUT}
fi

#Copy encryption files from sdb
mkdir /hdd & mkdir /ssd
mount /dev/${DISK_B} /ssd

cp -ax /ssd/home/.administrator/office-linux-encryption/ . && cd ./office-linux-encryption/

#Generate key for cryptsetup
./cdki-cl-keygen ${INTERFACE} /dev/${DISK_A} 4096 

KEY=`ip addr show dev ${INTERFACE} | grep -i ether | awk '{print $2}' | sed 's/:/-/g'`_*

echo "Generated key: ${KEY}"


#Encrypt entire sda with cryptsetup
echo "*** Starting encryption ***"
cryptsetup -d ${KEY} luksFormat /dev/${DISK_A} -s 512 -h sha512 -c aes-xts-plain64
cryptsetup -d ${KEY} luksOpen /dev/${DISK_A} ${DISK_A}

#Fix key name
./cdki-cl-fixkey ${KEY} /dev/${DISK_A}

KEY=`ip addr show dev ${INTERFACE} | grep -i ether | awk '{print $2}' | sed 's/:/-/g'`_*

#Copy key to server1
scp ${KEY} root@10.201.10.3:/home/backup/cdki/keys/

#Prepare file system for new OS
lvm pvcreate /dev/mapper/${DISK_A}
lvm vgcreate vg0 /dev/mapper/${DISK_A}
lvm lvcreate -L16G -n swap vg0
lvm lvcreate -l100%FREE -n root vg0

mkswap /dev/vg0/swap
mkfs.ext4 /dev/vg0/root

mount /dev/vg0/root /hdd

echo "*** Copying system files to encrypted drive ***"
cp -ax /ssd/* /hdd/

umount /dev/${DISK_B}
if [ $? -eq 0 ]; then
    echo -n "Please detach ${DISK_B} from the system. Type \"y\" when ready: "
    read ans
        until [ $ans = 'y' ]; do
                echo -n "Please detach ${DISK_B} from the system. Type \"y\" when ready: "
                read ans
        done
else
        continue
fi

mount --bind /dev/ /hdd/dev
mount --bind /dev/pts /hdd/dev/pts
mount --bind /sys /hdd/sys
mount --bind /proc/ /hdd/proc

chroot /hdd update-grub
chroot /hdd sed -i~ 's/UUID=.* \//\/dev\/vg0\/root \/ /' /etc/fstab
chroot /hdd sed -i~ 's/UUID=.* none/\/dev\/vg0\/swap none/' /etc/fstab

echo "*** Encryption has finished ***"

#!/bin/bash

hadoop_data_directory="/var/lib/hadoop-0.20/data"


# HDFS datanodes
#
# sd{e,f,g,h,i,j}1 become 300G ext3 partitions

for disk in /dev/sd{e,f,g,h,i,j}; do sudo fdisk $disk <<EOF
n
p
1


w
EOF

done


# sd{e,f,g,h,i,j}1 are HDFS data directories
# ext3 and moutned at /var/lib/hadoop-0.20/data/X
sudo mkdir -p $hadoop_data_directory
sudo chgrp hadoop $hadoop_data_directory
for disk_letter in e f g h i j ; do 
    partition="/dev/sd${disk_letter}1"
    data_directory="$hadoop_data_directory/${disk_letter}"
    
    sudo mkdir -pv $data_directory
    sudo chgrp hadoop $data_directory
    
    sudo mkfs.ext3 $partition
    grep -q $data_directory /etc/fstab || echo -e "# Hadoop data partition $disk_letter\n$partition\t$data_directory\text3\tdefaults,noatime\t0\t2" | sudo tee -a /etc/fstab    
    sudo tune2fs -m 0 $partition
    
    sudo mount -v $data_directory
    
    sudo mkdir -pv $data_directory/hdfs/dn
    sudo chown hdfs:hadoop $data_directory/{hdfs,hdfs/dn}
    sudo chmod 700 $data_directory/{hdfs,hdfs/dn}
    
    sudo -u mapred mkdir -pv $data_directory/mapred/local
    sudo chown mapred:hadoop $data_directory/{mapred,mapred/local}
done



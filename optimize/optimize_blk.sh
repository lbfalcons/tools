#!/bin/sh

# for centos 6.3( > 2.6.32 )
# only test at centos 6.3

# object:
#	using deadline io schedule

############## adjust io scheduler ###############################
# get subdev's name
disk_list_tmp=`mount | awk '{ print $1}' | grep "/dev/" | awk -F'/' '{print $3'}`

# get dev's name
disk_list=`for d in $disk_list_tmp
do
  echo $(expr $d : '\(.*\).')
done | sort | uniq`

for d in $disk_list
do
  echo "deadline" > /sys/class/block/$d/queue/scheduler
done

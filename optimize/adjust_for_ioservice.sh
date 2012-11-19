#!/bin/sh

# for centos 6.3( > 2.6.32 )
# only test at centos 6.3

# object:
# 	to banlance hardirq among cpus.
#	to banlance softirq among cpus.
#	adjust some tcp parament 
#	using deadline io scheduler

#network_dev_list=`ls /sys/class/net/ | egrep -v "lo|bond0|bonding_masters"`
network_dev_list=`/sbin/ifconfig | grep "Link encap" | awk '{ print $1}' | egrep -v "bond0|lo"`
bc=`which bc`
if [ -z $bc ] 
then 
  echo "need bc,install it"
  exit 0
fi


max_cpu=`grep processor /proc/cpuinfo | tail -n 1 | awk -F':' '{print $2}'`

# only run when the num of hard interrupt of the nic is same with cpu's num
function network_queue
{
  for d in $network_dev_list
  do
    irq_total=`grep $d /proc/interrupts | wc -l `
    irq_min=`grep $d /proc/interrupts | head -n 1 | awk -F':' '{ print $1}'`
    irq_max=$(($irq_min + $irq_total -1 ))

    cpu=1
    for i in `seq $irq_min 1 $irq_max`
    do
      cpu_hex=`echo "obase=16;$cpu" | bc`

      echo "$cpu_hex" > /proc/irq/$i/smp_affinity

      cpu=$(($cpu + $cpu))
    done
  done
}

function network_single
{

  # before adjust, all interrupt @cpu0
  cpu=1
  for d in $network_dev_list
  do
    cpu_hex=`echo "obase=16;$cpu" | bc`
    irq=`grep $d /proc/interrupts | head -n 1 | awk -F':' '{print $1}'`

    echo "$cpu_hex" > /proc/irq/$irq/smp_affinity

    cpu=$(($cpu + $cpu))

    if [ $cpu -gt $max_cpu ] 
    then
      cpu=1
    fi
  done
}

################ set hard interrupts ################################
#test_network_dev=`ls /sys/class/net/ | egrep -v "lo|bond0|bonding_masters" | head -n 1 `
test_network_dev=`/sbin/ifconfig  | grep "Link encap" | awk '{ print $1}' | egrep -v "bond0|lo" | head -n 1 `
test_irq_total=`grep $test_network_dev /proc/interrupts | wc -l `

if [ $test_irq_total -gt 1 ]
then
  network_queue
else
  network_single
fi

################  set rps/rfs  ########################################
# rps, set soft interrupts will run at all cpus
# rfs, set same <ip,port> will run at same cpus
#######################################################################
max_flow_entry=65536
single_flow_entry=$(( $max_flow_entry/$max_cpu ))

cpu_num=$(($max_cpu + 1 ))
rps=1
while [ $cpu_num -gt 0 ]
do
  rps=$(( $rps * 2))
  cpu_num=$(($cpu_num - 1 ))
done
rps=`echo "obase=16;$(($rps -1 ))" | bc`

echo $max_flow_entry > /proc/sys/net/core/rps_sock_flow_entries

for d in $network_dev_list
do
  for i in `seq 0 $(($test_irq_total-1))`
  do
    echo $rps |tee /sys/class/net/$d/queues/rx-$i/rps_cpus >/dev/null
    echo $single_flow_entry |tee /sys/class/net/$d/queues/rx-$i/rps_flow_cnt >/dev/null
  done
done


###############  adjust tcp ########################################
echo 10 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
#echo 180000 > /proc/sys/net/ipv4/tcp_max_tw_buckets

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

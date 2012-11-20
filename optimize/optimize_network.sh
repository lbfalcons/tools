#!/bin/sh

# for centos 6.3( > 2.6.32 )
# only test at centos 6.3

# object:
#	adjust some tcp parament 

###############  adjust tcp ########################################
echo 10 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
#echo 180000 > /proc/sys/net/ipv4/tcp_max_tw_buckets

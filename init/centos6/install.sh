#!/bin/sh

install="yum install -y "
erase="yum erase -y "

$erase vim-minimal
$install vim 
ln -s /usr/bin/vim /bin/vi

# network tools
software="openssh-server wget telnet iftop nc "
# developemnt tools
software+=" gcc gcc-c++ make gdb man man-pages ctags indent cmake clang  autoconf automake libtool pkgconfig perl-ExtUtils-MakeMaker tcl-devel pcre-devel ncurses-devel libcurl-devel libcap-devel hwloc-devel flex "

# monitor tools
software+=" sysstat file tree"
# compress tools
software+=" zip unzip lbzip2-utils"
# version control tools
software+=" git "
# for lscpu,lsblk
software+=" util-linux-ng"
# profiler
software+=" perf "

yum install epel-release -y

$install $software



function disp
{
  echo "download $1  from $2"
}
  
  
# to display cpu topology
#disp "intel performance tuning utility" "http://software.intel.com/en-us/articles/intel-performance-tuning-utility/"])


# for git
git config --global http.postBuffer 524288000

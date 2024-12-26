#!/bin/bash
#MGTNET=ens37            #管理网卡名字
#MGTIP=192.168.8.102     #管理ip地址
#MGTMASK=24	        #管理子网掩码
#BONDNAME=bond0          #bond名字(自定义)
#BONDSLAVE1=ens38        #业务1网卡
#BONDSLAVE2=ens39        #业务2网卡
#BONDTYPE=active-backup  #bond的类型  主备
#ROUTETARGET=192.168.8.0/24  #管理网路由目的
#ROUTEVIA=192.168.8.50   #管理网路由下一跳
read -p "将那两个网卡做绑定-网卡1的名字:" BOND1
read -p "网卡2的名字: " BOND2
read -p "请输入bond的名字(例如bond0): " BONDNAME
#read -p "请输入bond的类型(例如active-backup):" BONDTYPE
read -p "请输入bond的ip地址: " BONDIP
read -p "请输入bond的子网掩码(例如24): " BONDMASK
read -p "请输入bond的网关:" BONDGAW
read -p "请输入管理网路由的下一跳" MGT
read -p "请输入管理网卡名字"    MGTNAME
nmcli con add type bond con-name ${BONDNAME} ifname bond0 mode active-backup &>/dev/null
nmcli con add type bond-slave ifname ${BOND1} master ${BONDNAME} &>/dev/null
nmcli con add type bond-slave ifname ${BOND2} master ${BONDNAME} &>/dev/null
nmcli con mod ${BONDNAME} ipv4.addresses ${BONDIP}/${BONDMASK} ipv4.gateway ${BONDGAW} ipv4.method manual &>/dev/null
nmcli con reload && nmcli con up ${BONDNAME} &>/dev/null
ip route add 50.1.0.0/16 via ${MGT} dev ${MGTNAME}
ifconfig ${BONDNAME}

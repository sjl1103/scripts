#!/bin/bash
BACKUP_DIR=/etcd-backup/
ETCD_IP=192.168.8.128
CACERT=/etc/kubernetes/pki/etcd/ca.crt
CERT=/etc/kubernetes/pki/etcd/server.crt
KEY=/etc/kubernetes/pki/etcd/server.key
BACKUP_NAME=etcd-backup
time=$(date +%F-%T)
error=/etcd-backup-error/error.log
error1=/etcd-backup-error/error1.log

read -p "备份数据输入1|恢复数据输入2  请输入: " num
if [ $num -eq 1 ];then
	ETCDCTL_API=3 etcdctl --endpoints=https://${ETCD_IP}:2379 --cacert=${CACERT} --cert=${CERT} --key=${KEY} snapshot save ${BACKUP_DIR}${BACKUP_NAME}_$(date +%F-%T).db &> ${error}
	if [ $? -eq 0 ];then
		echo "ETCD数据已经备份完成，文件名: ${BACKUP_NAME}_$(date +%F-%T).db,请在${BACKUP_DIR}中查看"
	else
		echo "备份失败，错误信息请查看${error}文件"
	fi
elif [ $num -eq 2 ];then
	ls ${BACKUP_DIR}
	read -p "请输入需要恢复的数据文件:" file
	read -p "请输入etcd实例的名字,例如master上面的就写etcd-master01:" etcdname
	mv /etc/kubernetes/manifests/*  /opt/backup/
	rm -rf /var/lib/etcd/
	ETCDCTL_API=3 etcdctl snapshot restore ${BACKUP_DIR}${file} --name ${etcdname} --data-dir /var/lib/etcd --initial-cluster etcd-master01=https://${ETCD_IP}:2380 --initial-cluster-token etcd-cluster-token --initial-advertise-peer-urls https://${ETCD_IP}:2380  &> ${error1}
	if [ $? -eq 0 ];then
		mv /opt/backup/* /etc/kubernetes/manifests/
		echo "恢复完成,请验证数据是否正确"
	else
		echo "恢复失败，错误信息请查看${error1}文件"
	fi
fi

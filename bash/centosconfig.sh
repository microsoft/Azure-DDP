mkdir /root/scripts
mv makefilesystem.sh /root/scripts/makefilesystem.sh
chmod 755 /root/scripts/makefilesystem.sh
yum -y install dos2unix
dos2unix /root/scripts/makefilesystem.sh /root/scripts/makefilesystem.sh
#disable iptables
chkconfig iptables off
/etc/init.d/iptables stop
setenforce 0
#start ntp service
yum -y install ntp
chkconfig ntpd on
ntpdate pool.ntp.org
echo 'vm.swappiness = 0' >> /etc/sysctl.conf 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled">>/etc/rc.local
echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag">>/etc/rc.local
ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
if [ $ip = "172.16.0.4" ] ; then
 reboot now
fi

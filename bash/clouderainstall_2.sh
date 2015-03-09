echo [cloudera-manager] \# Packages for Cloudera Manager, Version 5, on RedHat or CentOS 6 x86_64 name=Cloudera Manager baseurl=http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/ gpgkey = http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera gpgcheck = 1 > /etc/yum.repos.d/cloudera-manager.repo
yum clean all
yum -y install oracle-j2sdk1.7
yum -y install cloudera-manager-server-db-2
service cloudera-scm-server-db-start
service cloudera-scm-server start

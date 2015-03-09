wget http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo -P /etc/yum.repos.d/
yum clean all
yum -y install oracle-j2sdk1.7
yum -y install cloudera-manager-server-db-2
service cloudera-scm-server-db-start
service cloudera-scm-server start

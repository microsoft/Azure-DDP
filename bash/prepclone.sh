sed -i 's/Provisioning.DeleteRootPassword=y/Provisioning.DeleteRootPassword=n/g' /etc/waagent.conf
sed -i 's/Provisioning.RegenerateSshHostKeyPair=y/Provisioning.RegenerateSshHostKeyPair=n/g' /etc/waagent.conf
waagent -deprovision -force

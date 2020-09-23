#!/bin/sh

yum install -y https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el7.noarch.rpm
yum clean expire-cache
yum install salt-minion

systemctl start salt-minion
systemctl enable salt-minion
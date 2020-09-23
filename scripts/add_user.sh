#!/bin/sh

USER=$1

useradd -m -s /bin/bash -U $USER -u 666 --group wheel
cp -pr /home/vagrant/.ssh /home/${USER}/.ssh
mv /tmp/id_rsa.pub /home/${USER}/.ssh/authorized_keys
chown -R ${USER}:${USER} /home/${USER}
echo "%${User} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
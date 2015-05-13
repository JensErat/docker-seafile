#!/bin/sh

cd /opt/seafile
arch=$(uname -m | sed s/"_"/"-"/g)
regexp="http(s?):\/\/[^ \"\(\)\<\>]*seafile-server_[\d\.\_]*$arch.tar.gz"
addr=`wget http://www.seafile.com/en/download/ -O - | grep --only-matching --perl-regexp "$regexp" | head -1`
curl -L -O $addr || curl -L -O https://bitbucket.org/haiwen/seafile/downloads/seafile-server_4.1.2_x86-64.tar.gz;
tar xzf seafile-server_*
mkdir -p installed
mv seafile-server_* installed

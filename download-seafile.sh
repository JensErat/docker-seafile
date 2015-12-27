#!/bin/bash

cd /opt/seafile
arch=$(uname -m | sed s/"_"/"-"/g)
regexp="http(s?):\/\/[^ \"\(\)\<\>]*seafile-server_[\d\.\_]*$arch.tar.gz"

which wget > /dev/null
wget=$?
which curl > /dev/null
curl=$?
if [ $wget -eq 0 ]; then
    addr=$(wget https://www.seafile.com/en/download/ -O - | grep -o -P "$regexp" | head -1)
    wget $addr
elif [ $curl -eq 0 ]; then
    addr=$(curl -Ls https://www.seafile.com/en/download/ | grep -o -P "$regexp" | head -1)
    curl -Ls -O $addr 
else
    echo "Neither curl nor wget found. Exiting."
    exit 1
fi

# figure out what directory the tarball is going to create
file=$( echo $addr | awk -F/ '{ print $NF }' )

# test that we got something
if [ ! -z $file -a -f $file ]; then
    dir=$( tar tvzf $file 2>/dev/null | head -n 1 | awk '{ print $NF }' | sed -e 's!/!!g')
    tar xzf $file

    # mkdir only if we don't already have one
    [ ! -d installed ] && mkdir installed

    # move the tarball only if we created the directory
    [ -d $dir ] && mv seafile-server_* installed
else
    echo "Seafile install file not downloaded. Exiting."
    exit 1
fi

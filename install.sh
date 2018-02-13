#!/bin/bash

# Create temporary directory with install files.
BINTEMP=`mktemp -d 2>/dev/null || mktemp -d -t 'bsd-install'`
cd $BINTEMP

# Copy repository and extract into tmp directory
curl -sL https://github.com/blacksheepdesign/bsd-scripts/archive/master.tar.gz | tar xz

# Copy the scripts to /usr/local
sudo rsync -a $BINTEMP/ /usr/local/bsd-scripts/

# Symlink the script
rm -f /usr/local/bin/bsd
ln -s /usr/local/bsd-scripts/bsd.sh /usr/local/bin/bsd
echo
echo 'Install complete!'

rm -rf $BINTEMP
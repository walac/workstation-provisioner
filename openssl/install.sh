#!/bin/bash -vex

if openssl version | grep 'OpenSSL 1\.1'; then
  exit 0
fi

version=1.1.1a
filename=openssl-$version.tar.gz

url=https://www.openssl.org/source/$filename

pushd /tmp
rm -rf openssl*
wget $url
tar -xzf $filename
cd ${filename%%.tar.gz}
./config
make
make test
sudo make install
popd

sudo ldconfig
openssl version

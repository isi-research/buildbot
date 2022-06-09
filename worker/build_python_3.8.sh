#!/usr/bin/env bash
#----------------------------------------------------------------------------------
#
#  Multimodal Apps for Robotic Surgery
#
#  Any direct or indirect use of this code in any form is only permitted subject
#  to a written agreement with Intuitive Surgical Inc. Any information, ideas or
#  property, whether intellectual or otherwise, that result from any unauthorized
#  use of this software shall be the sole property of Intuitive Surgical, Inc.
#
#  Copyright (C) 2022 Intuitive Surgical, Inc. All Rights Reserved.
#
#  Created on: May 18, 2022
#  Authors   : Min Yang Jung
#
#  Script to build Python 3.8 from source.  This script is an adapted version of
#  https://github.com/bdbaddog/python_build_scripts/blob/master/full_build_38.sh
#
#  This script compiles Python 3.8.3 from source and installs build artifacts
#  to /opt/isi/python-3.8.3 directory.
#
#  If you install Python using this script, make sure add the install directory
#  to PATH environment variable so that the build install scripts can find the
#  python executable built by this script.
#
#----------------------------------------------------------------------------------
#
set -ex

echo << BLAH
If this fails on ubuntu, you may need to run this command:
sudo apt-get install -y build-essential git libexpat1-dev libssl-dev zlib1g-dev \
     libncurses5-dev libbz2-dev liblzma-dev libsqlite3-dev libffi-dev tcl-dev \
     linux-headers-generic libgdbm-dev libreadline-dev tk tk-dev
BLAH

base_dir=/opt/isi
python_version=3.8.3
#https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz
python_dir=python-${python_version}
kits_dir=${base_dir}/kits
install_dir=${base_dir}/${python_dir}

mkdir -p ${kits_dir} ${install_dir}/lib
chown -R buildbot ${kits_dir} ${install_dir}

libxml2_version=2.9.3

# Make sure libssl-dev and libffi-dev are installed.  Without them, Python build
# still succeeds but fails at run-time.
apt-get install libssl-dev libffi-dev

pushd ${kits_dir}
if [ ! -f Python-${python_version}.tgz ]; then
    wget https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz
fi

#if [ ! -f libxml2-${libxml2_version}.tar.gz ]; then
    #wget ftp://xmlsoft.org/libxml2/libxml2-${libxml2_version}.tar.gz
#fi

#if [ ! -f libxslt-1.1.28.tar.gz ]; then
    #wget ftp://xmlsoft.org/libxml2/libxslt-1.1.28.tar.gz
#fi

tar xvfz Python-${python_version}.tgz
#tar xvfz libxml2-${libxml2_version}.tar.gz
#tar xvfz libxslt-1.1.28.tar.gz

export PATH=${install_dir}/bin:$PATH
mkdir -p ${install_dir}/lib

pushd Python-${python_version}
LDFLAGS="-Wl,-rpath=${install_dir}/lib" ./configure --prefix=/usr \
  --enable-loadable-sqlite-extensions \
  --enable-shared \
  --with-lto \
  --enable-optimizations \
  --enable-ipv6 \
  --with-system-expat
#  --enable-unicode \
#  --enable-ipv6 --with-threads
#  --with-system-ffi \
#  --enable-ipv6 --with-threads --with-pydebug

NCORE=32
[ -x "$(command -v nproc)" ] && NCORE=$(nproc --all)
echo "Detected ${NCORE} cores on this machine"

make -j $NCORE
make install
popd

#pushd libxml2-${libxml2_version}
#make distclean || true
#LDFLAGS="-Wl,-rpath=$HOME/tools/python-${python_version}/lib" ./configure --prefix=${install_dir} --enable-shared --with-python=${install_dir}/bin/python3
#make
#make install
#popd
#
#pushd libxslt-1.1.28
#LDFLAGS="-Wl,-rpath=$HOME/tools/python-${python_version}/lib" ./configure --prefix=${install_dir} --enable-shared --with-python=${install_dir}/bin/python3
#make
#make install
#popd

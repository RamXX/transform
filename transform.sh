#!/bin/bash
# Script to download a raw OpenStack BOSH stemcell and convert it
# to a bootable format under VMware Integrated OpenStack.
# --------------------------
# usage: transform.sh <URL>
# Downloads, transforms and return the new stemcell in the CWD
# --------------------------

URL="$1"
T=/tmp/target
C=$(pwd)

if [ -z "$URL" ]; then
  echo "Please pass the URL of the stemcell as a parameter"
  exit 1
fi

if [ "$(echo $URL | grep :// | sed -e's,^\(.*://\).*,\1,g')" != "https://" ]; then
  echo "Please pass a HTTPS URL as a parameter"
  exit 1
fi

fname="$(echo $URL | grep / | cut -d/ -f5-)"
version="$(echo $fname | grep -- - | cut -d\- -f3)"

mkdir -p $T/unpack && cd $T
echo "Downloading stemcell..."
wget -O target.tgz "$URL"

echo "Unpacking stemcell..."
cd unpack
tar xzf ../target.tgz && rm -f ../target.tgz
mkdir -p unpack2 && cd unpack2
tar xzf ../image && rm -f ../image

echo "Transforming stemcell..."
qemu-img convert root.img -f raw -O vmdk -o \
 subformat=streamOptimized,adapter_type=lsilogic stemcell.vmdk

printf '\x03' | dd conv=notrunc of=stemcell.vmdk bs=1 seek=$((0x4)) 2> /dev/null
mv stemcell.vmdk root.img

echo "Repackaging stemcell..."
tar czf ../image root.img && cd ..
rm -rf unpack2
SHA1=$(sha1sum image)

cat <<EOF > stemcell.MF
name: bosh-openstack-vmdk-ubuntu-trusty-go_agent-raw
version: '$version'
bosh_protocol: 1
sha1: $SHA1
operating_system: ubuntu-trusty
cloud_properties:
  name: bosh-openstack-vmdk-ubuntu-trusty-go_agent-vio
  version: '$version'
  infrastructure: vsphere
  disk: 3072
  disk_format: vmdk
  container_format: bare
  root_device_name: "/dev/sda1"
EOF

target="$C/vio-$fname"
tar czf "$target" *
cd "$C"
echo "Transformed stemcell saved as $target"
echo "All done."

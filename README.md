# transform
Downloads an OpenStack RAW stemcell and converts it to a VMDK format usable in VIO

usage: transform.sh URL

The URL needs to be https and the name of the stemcell needs to be in a common format like bosh-stemcell-3421.21-openstack-kvm-ubuntu-trusty-go_agent-raw.tgz.

The result will be a transformed stemcell with the same name `vio-` prefix in the current working directory.

The stemcell version will be the actual version of the image if the REALVERSION variable is set. Otherwise, the script will hard code 3312.28, which is the latest version accepted by Ops Manager.

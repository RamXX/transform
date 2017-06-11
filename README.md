# transform
Downloads an OpenStack RAW stemcell and converts it to a VMDK format usable in VIO

usage: transform.sh URL

The URL needs to be https and the name of the stemcell needs to be in a common format like bosh-stemcell-3421.21-openstack-kvm-ubuntu-trusty-go_agent-raw.tgz.

The result will be a transformed stemcell with the same name and version with `vio-` prefix in the current working directory.

#!/bin/sh
sudo puppet apply  --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:./modules manifests

#!/bin/sh
sudo puppet apply  --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:./modules --templatedir /root/mail-server-puppet/templates /root/mail-server-puppet/manifests
#sudo puppet apply  --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:./modules --templatedir templates manifests

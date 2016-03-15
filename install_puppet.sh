#!/bin/sh
if ! which puppet > /dev/null; then
	wget https://apt.puppetlabs.com/puppetlabs-release-stable.deb
	sudo dpkg -i puppetlabs-release-stable.deb
	sudo apt-get --assume-yes update
	sudo apt-get --assume-yes install puppet
fi;

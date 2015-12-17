#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Temporarily disable dpkg fsync to make building faster.
if [[ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]]; then
	echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
fi

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

apt-get update

## Install HTTPS support for APT.
$minimal_apt_get_install apt-transport-https ca-certificates

## Install add-apt-repository
$minimal_apt_get_install software-properties-common

## Install local-gen
$minimal_apt_get_install locales

## Upgrade all packages.
apt-get dist-upgrade -y --no-install-recommends

## Update locale settings
echo "en_CA.UTF-8 UTF-8" > /etc/locale.gen
locale-gen en_CA.UTF-8
update-locale LANG=en_CA.UTF-8
echo -n en_CA.UTF-8 > /etc/container_environment/LANG
echo -n en_CA.UTF-8 > /etc/container_environment/LC_CTYPE

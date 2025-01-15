#!/bin/sh

# Debian and Ubuntu builds of Buildah patch out heredoc support because of a old
# Docker / Buildkit frontend parser version. In some future Ubuntu release this
# will be fixed as a newer Docker has landed in upstream Debian Sid/Unstable.
# (see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1072578)
#
# Until then, install buildah from Sid to get heredoc support.

sudo apt update
sudo apt install debian-keyring debian-archive-keyring

cat <<EOF | sudo tee /etc/apt/sources.list.d/debian-sid.sources
Types: deb
# http://snapshot.debian.org/archive/debian/20241016T000000Z
URIs: http://deb.debian.org/debian
Suites: sid
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
cat <<EOF | sudo tee /etc/apt/preferences.d/debian-sid.pref
Package: *
Pin: release o=Debian,a=unstable,n=sid
Pin-Priority: 100
EOF

sudo apt update
sudo apt install buildah/sid crun/sid libgpgme11t64/sid

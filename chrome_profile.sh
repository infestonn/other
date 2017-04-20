#!/bin/bash

PROFILE=profile_`date +"%F-%s"`
echo $PROFILE

for i in $(find ~/.cache/google-chrome/ -name "profile_*"); do
        mv $i/ ~/.local/share/Trash/files
done

cd `mktemp -d` && wget http://dev-proxy.ua.netvertise.com/clean.tar.gz

mkdir ~/.config/google-chrome/$PROFILE && tar -xf * --strip-components=1 -C ~/.config/google-chrome/$PROFILE

google-chrome --profile-directory=$PROFILE

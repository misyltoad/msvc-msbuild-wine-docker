#!/bin/bash

docker build . -t msvc-wine
docker run -v /home/joshua/Code:/code -e WINEPREFIX=/opt/msvc/pfx --user $(id -u):$(id -g) -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -e WINEDEBUG=-all --rm -it --entrypoint bash msvc-wine

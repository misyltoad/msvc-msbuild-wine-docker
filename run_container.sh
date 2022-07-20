#!/bin/bash

docker build . -t msvc-wine
docker run -v /home/joshua/Code:/code -e WINEDEBUG=-all --rm -it --entrypoint bash msvc-wine

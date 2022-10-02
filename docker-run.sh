#!/usr/bin/env bash

docker run --rm --init -it --mount="type=bind,src=$(pwd),dst=/rendercontrol3d/images,consistency=cached" rendercontrol3d

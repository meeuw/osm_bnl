#!/bin/bash

declare -a ARGS=("osmosis/osmosis*/bin/osmosis")

for ARG in "${@}" ; do
    ARGS+=("--rbf $ARG")
done

shift 1
for ARG in "${@}" ; do
    ARGS+=("--merge")
done

ARGS+=("--wb merged.osm.pbf")

${ARGS[@]}

#!/bin/bash
TAGNAME="joostvdg-cloudbees-image"

echo "# Building new image with tag: $TAGNAME"
docker build --tag=$TAGNAME .

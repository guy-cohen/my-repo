#!/bin/bash

FILES=/Users/guyco/Work/debian/*

for f in $FILES
do
  echo "Processing $f file..."
  jfrog rt u $f debian-local --url=http://localhost:8081/artifactory --deb="wheezy/main/i386" --user=admin --password=password --flat=true  --props=Version=1.0

done

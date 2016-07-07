#!/bin/bash

echo "Creating new instance"
jfrog mc rt-instances add onprem-instance --rt-url=http://localhost:8081/artifactory --rt-user=admin --rt-password=password

sleep 1

jfrog mc rt-instances add my-aol --rt-url=https://guyco.artifactoryonline.com/guyco --rt-user=admin --rt-password=password

echo "Done"

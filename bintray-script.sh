#!/bin/bash

jfrog bt package-create guy-org/cli-repo/test-package --user=guyco --key=0ade7dfa24131940db1110b114583f1ea717fe9f --licenses=GPL-3.0 --vcs-url=https://sort.veritas.com/public/documents/sf/5.0MP3/aix/html/vcs_users/ch_admin_vcs_from_cli9.html --desc="Created via CLI"

sleep 2
echo "Successfuly created new package"

jfrog bt vc guy-org/cli-repo/test-package/1.0
echo "Successfuly created new version"

echo "Uploading files"
sleep 2

jfrog bt u "/Users/guyco/Desktop/uploads/*" guy-org/cli-repo/test-package/1.0

sleep 2

jfrog bt vp guy-org/cli-repo/test-package/1.0

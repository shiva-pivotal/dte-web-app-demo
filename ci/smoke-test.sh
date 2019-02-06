#!/usr/bin/env bash
set -e

get_code="curl -k -I https://dte-web-app-demo-dev.cfapps.haas-81.pez.pivotal.io/ 2>/dev/null | head -n 1 | cut -d ' ' -f2"
status_code=`eval $get_code`
echo $status_code

if [ "$status_code" != "200" ]
then
  echo "Expect status code from https://dte-web-app-demo-dev.cfapps.haas-81.pez.pivotal.io/ as 200, but got $status_code"
  exit 1
fi
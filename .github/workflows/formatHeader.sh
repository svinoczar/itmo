#!/bin/bash

original=$1

header=$(echo ${original//"#"/} | awk '{$1=$1};1')
partheader=$(echo ${header//:/} | sed -e 's/([^()]*)//g' | awk '{$1=$1};1')
header=$(echo ${partheader// /-} | grep -o -P '[A-Za-z0-9-]+' | tr -d '\n' | sed -e 's/\(.*\)/\L\1/')

echo $header
#!/bin/bash

#Create a script that checks if a directory exists; if not, create it

dir="/var/log/solr"
if [ -d $dir ];then
 echo "Directory already exists : $dir"
else
 echo "Directory does not exist, creating....."
 mkdir -p $dir
 echo "Directory created: $dir"
fi

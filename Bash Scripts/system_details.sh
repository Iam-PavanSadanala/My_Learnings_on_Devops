#!/bin/bash

echo "Getting Hostname.............."
Host=$(hostname)
echo "Hostname is $Host"
echo 'Getting kernel Info.................'
kernelInfo=$(uname -r)
echo "Kernel Info - $kernelInfo"
echo -n "uptime of the server is $(uptime)"

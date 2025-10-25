#!/bin/bash
# This script can be used for additional Forgejo configuration
cd /opt/forgejo
./forgejo admin user create --admin --username admin --password admin1234 --email admin@localhost

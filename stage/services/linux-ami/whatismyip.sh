#!/bin/bash

# Using '+short' opt will hide source addr/port num of server. -4 flag obviously grabs IPV4
INTERNETIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
# Parse via locally installed JSON parser. Use '-n' to ignore input and construct JSON manually
# Passing val to '--arg' makes it availabe with value stored in variable (i.e, my public IP in this case)
echo $(jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}') # Binds pub IP stored in --arg to new k/v pair

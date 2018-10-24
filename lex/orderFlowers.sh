#!/bin/bash

# Lex script
# 1. set AWS creds environment variables

AWS_DEFAULT_REGION=us-east-1
USER_ID=`date | md5sum | head -c 8`
BASE_COMMAND="aws lex-runtime post-text --bot-name OrderFlowers --bot-alias LATEST --user-id $USER_ID"

response1=`$BASE_COMMAND --input-text "Hello I would like to order flowers"`
echo $response1 | jq '.message'
# "What type of flowers would you like to order?"

response2=`$BASE_COMMAND --input-text "Roses"`
echo $response2 | jq '.message'
# 

response3=`$BASE_COMMAND --input-text "Friday"`
echo $response3 | jq '.message'
#

response4=`$BASE_COMMAND --input-text "9 in the morning"`
echo $response4 | jq '.message'

response5=`$BASE_COMMAND --input-text "OK"`
echo $response5 | jq '.slots'
echo $response5 | jq '.dialogState'
echo $response5 
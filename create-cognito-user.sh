#!/bin/bash
set -ev
echo "Creating cognito user..."

echo "DEBUG print variables"
echo "USER_POOL_ID=$USER_POOL_ID"
echo "USER_POOL_CLIENT_ID=$USER_POOL_CLIENT_ID"
echo "TEST_USER_SECRET_ID=$TEST_USER_SECRET_ID"
echo "TEST_USER_NAME=$TEST_USER_NAME"
echo "TEST_USER_NAME=$TEST_USER_CRED"

echo "Checking for required environment variables..."
# Check for required Environment Variables:
: "${USER_POOL_ID?USER_POOL_ID needs to be set}"
: "${USER_POOL_CLIENT_ID?USER_POOL_CLIENT_ID needs to be set}"
: "${TEST_USER_SECRET_ID?TEST_USER_SECRET_ID needs to be set}"
: "${TEST_USER_NAME?TEST_USER_NAME needs to be set}"
: "${TEST_USER_NAME?TEST_USER_NAME needs to be set}"
: "${TEST_USER_CRED?TEST_USER_CRED needs to be set}"
: "${FOOBAR?FOOBAR needs to be set}"

TEST_USER_TEMP_CRED=Temp123.
# USER_POOL_ID=us-east-1_2W4VMIOMM
# USER_POOL_CLIENT_ID=1r11m32pc30uepc04k46qv4n61
# TEST_USER_SECRET_ID=REMOVE_ME
# TEST_USER_NAME=user04
# TEST_USER_CRED=`date | md5sum | head -c${1:-10}`

# Check if the test user exists.
aws cognito-idp admin-get-user --user-pool-id $USER_POOL_ID --username $TEST_USER_NAME
if [ $? -ne 0 ]; then

    # 1. setup test user.
    echo "Creating user = $TEST_USER_NAME" | jq -r '.UserStatus'
    aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $TEST_USER_NAME --temporary-password $TEST_USER_TEMP_CRED
	echo "Getting session key administratively as test user"
	SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $USER_POOL_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$TEST_USER_NAME,PASSWORD=$TEST_USER_TEMP_CRED | jq -r ".Session"`
	echo "Confirming user by responding to auth challenge..."
	aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $USER_POOL_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$TEST_USER_CRED,USERNAME=$TEST_USER_NAME,userAttributes.name=$TEST_USER_NAME --session $SESSION_KEY
	echo "Verifying authentication as the test user to retrieve OAUTH_ID_TOKEN JWT Bearer token" 
	OAUTH_ID_TOKEN=`aws cognito-idp initiate-auth --client-id $USER_POOL_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$DESIRED_PASSWORD | jq -r ".AuthenticationResult.IdToken"`
	echo "#debug# OAUTH_ID_TOKEN=$OAUTH_ID_TOKEN"

	# 1. Write Secrets.
	SECRET_STRING='[{"username":"' 
	SECRET_STRING+=$TEST_USER_NAME
	SECRET_STRING+='"},{"password":"'
	SECRET_STRING+=$TEST_USER_CRED
	SECRET_STRING+='"}]'
	echo "SECRET_STRING=$SECRET_STRING"
	echo "writing test secret to TEST_USER_SECRET_ID=$TEST_USER_SECRET_ID"
	aws secretsmanager create-secret --name $TEST_USER_SECRET_ID --description "Test user cred" --secret-string $SECRET_STRING

	echo "completed test user setup"

fi

echo "completed"

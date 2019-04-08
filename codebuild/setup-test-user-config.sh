#!/bin/bash
# 
# Setup Cognito test user, with cred set in SecretsManager 
#
set -e
echo "Creating cognito user..."

echo "DEBUG printing variables..."
echo "IDENTITY_POOL_ID=$IDENTITY_POOL_ID"
echo "USER_POOL_ID=$USER_POOL_ID"
echo "USER_POOL_CLIENT_ID=$USER_POOL_CLIENT_ID"
echo "API_URL=$API_URL"
echo "TEST_USER_SECRET_ID=$TEST_USER_SECRET_ID"
echo "TEST_USER_NAME=$TEST_USER_NAME"

echo "Checking for required environment variables..."
: "${IDENTITY_POOL_ID?IDENTITY_POOL_ID needs to be set}"
: "${USER_POOL_ID?USER_POOL_ID needs to be set}"
: "${USER_POOL_CLIENT_ID?USER_POOL_CLIENT_ID needs to be set}"
: "${API_URL?API_URL needs to be set}"
: "${TEST_USER_SECRET_ID?TEST_USER_SECRET_ID needs to be set}"
: "${TEST_USER_NAME?TEST_USER_NAME needs to be set}"


# Sanity check that the config file exists.
if [ ! -f $JS_CONFIG_FILE ]; then
    echo "Confing File not found! Expected at: $JS_CONFIG_FILE"
    exit 255
fi

TEST_USER_CRED=`date | md5sum | head -c${1:-10}`
TEST_USER_TEMP_CRED=Temp123.

# Create the user, if it doesn't exist

USER_EXISTS_RC=-1
aws cognito-idp admin-get-user --user-pool-id $USER_POOL_ID --username $TEST_USER_NAME && USER_EXISTS_RC=$? || USER_EXISTS_RC=$?
echo "USER_EXISTS_RC=$USER_EXISTS_RC"

if [ $USER_EXISTS_RC -ne 0 ]
then

    # Create and Confirm test user.
    echo "User=$TEST_USER_NAME not found, Creating user..."
    aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $TEST_USER_NAME --temporary-password $TEST_USER_TEMP_CRED
	
	echo "Getting session key administratively as test user"
	SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $USER_POOL_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$TEST_USER_NAME,PASSWORD=$TEST_USER_TEMP_CRED | ./jq -r ".Session"`
	
	echo "Confirming user by responding to auth challenge..."
	aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $USER_POOL_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$TEST_USER_CRED,USERNAME=$TEST_USER_NAME,userAttributes.name=$TEST_USER_NAME --session $SESSION_KEY
	
	# Write cred to SecretsManager.
	SECRET_STRING='[{"username":"' 
	SECRET_STRING+=$TEST_USER_NAME
	SECRET_STRING+='"},{"password":"'
	SECRET_STRING+=$TEST_USER_CRED
	SECRET_STRING+='"}]'
	echo "SECRET_STRING=$SECRET_STRING"
	echo "writing test secret to TEST_USER_SECRET_ID=$TEST_USER_SECRET_ID"
	SECRET_EXISTS_RC=-1
	SECRET_EXISTS_RC=`aws secretsmanager describe-secret --secret-id $TEST_USER_SECRET_ID`
	if [ $SECRET_EXISTS_RC -eq 0 ]
	then
		aws secretsmanager update-secret --secret-id $TEST_USER_SECRET_ID --description "Test user cred, updated." --secret-string $SECRET_STRING
 	else
		aws secretsmanager create-secret --name $TEST_USER_SECRET_ID --description "Test user cred, created." --secret-string $SECRET_STRING
	fi
	echo "Completed setup of Cognito test user=$TEST_USER_NAME"

else

    # Read the cred from Secrets Manager
	echo "Cognito test user=$TEST_USER_NAME already exists. Retrieving test creds."
	TEST_USER_CRED=`aws secretsmanager get-secret-value --secret-id $TEST_USER_SECRET_ID`
	TEST_USER_CRED=`echo $TEST_USER_CRED | ./jq -r '.SecretString' | ./jq  -r '.[].password | select(length>0)'`

fi

echo "Verifying authentication as the test user to retrieve OAUTH_ID_TOKEN JWT Bearer token" 
OAUTH_ID_TOKEN=`aws cognito-idp initiate-auth --client-id $USER_POOL_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$TEST_USER_NAME,PASSWORD=$TEST_USER_CRED | jq -r ".AuthenticationResult.IdToken"`

# Update website Javascript config
echo "Setting parameters into the website config.js file, at: $JS_CONFIG_FILE"
sed -i -e "s/\('region'[[:space:]]*:\).*$/\1 '$AWS_DEFAULT_REGION',/g" $JS_CONFIG_FILE
sed -i -e "s/\('identity_pool_id'[[:space:]]*:\).*$/\1 '$IDENTITY_POOL_ID',/g" $JS_CONFIG_FILE
sed -i -e "s/\('user_pool_id'[[:space:]]*:\).*$/\1 '$USER_POOL_ID',/g" $JS_CONFIG_FILE
sed -i -e "s/\('user_pool_client_id'[[:space:]]*:\).*$/\1 '$USER_POOL_CLIENT_ID',/g" $JS_CONFIG_FILE
sed -i -e "s|\('api_url'[[:space:]]*:\).*$|\1 '$API_URL',|g" $JS_CONFIG_FILE
sed -i -e "s/\('test_user_name'[[:space:]]*:\).*$/\1 '$TEST_USER_NAME',/g" $JS_CONFIG_FILE
sed -i -e "s/\('test_user_cred'[[:space:]]*:\).*$/\1 '$TEST_USER_CRED'/g" $JS_CONFIG_FILE

cat $JS_CONFIG_FILE


# Cognito Test Stack

## Installing: Deploy the stack

Deploy the stack. Replace ```TestUserEmail``` parameter with a valid email address, A temporary password will be emailed to you.

```
EMAIL=frankang+changeme@amazon.com

aws cloudformation deploy --capabilities CAPABILITY_IAM --template-file ./cognito-cfn.yaml  --parameter-overrides "TestUserEmail=$EMAIL" --stack-name CognitoTestStack03
```

## Confirm the test user 

The stack creates one demo user for the demo web GUI. The demo user is initially in ```FORCE_CHANGE_PASSWORD``` state, and the temporary password will be emailed to the provided ```TestUserEmail``` email address.

Initiate auth on behalf of the user. First lets set some properties:

```
# Fill in values for your environment:
USER_POOL_ID=
APP_CLIENT_ID=
USERNAME=
CURRENT_PASSWORD=
DESIRED_PASSWORD=
BOT_URL=
```
Next, authenticate administratively with the user temp password, to get a session key.
Then reset the password administratively. 
```
SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$CURRENT_PASSWORD | jq -r ".Session"`

aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$DESIRED_PASSWORD,USERNAME=$USERNAME,userAttributes.name=$USERNAME --session $SESSION_KEY
```

## Test authentication with the demo user

Authenticate as the demo user and retrieve the OAUTH_ID_TOKEN. This is a JWT Bearer token. 

```
OAUTH_ID_TOKEN=`aws cognito-idp initiate-auth --client-id $APP_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$DESIRED_PASSWORD | jq -r ".AuthenticationResult.IdToken"`
```

The following test will only work if you have configured the API endpoint. 
Send the authenticated curl request to the bot. Note the use of HTTP Authorization header.

```
curl -X POST -H "content-type: application/json" -H "Authorization: $OAUTH_ID_TOKEN"  --data '{ "intent":"我想订花", "userid":"bar"}' $BOT_URL; echo
```

## Miscellaneous procedures

### Sign Up new users
```
aws cognito-idp sign-up --client-id $APP_CLIENT_ID \
 --username $USERNAME --password $DESIRED_PASSWORD \
 --user-attributes Name=name,Value=$USERNAME Name=email,Value=$EMAIL

aws cognito-idp admin-confirm-sign-up \
  --user-pool-id $USER_POOL_ID \
  --username $USERNAME
```


### Admin create users

```
# Parameters
USER_POOL_ID=us-east-1_2W4VMIOMM
USERNAME=user02
TEMP_PASSWORD=Temp123.

# does the user exist?
aws cognito-idp  admin-get-user --user-pool-id $USER_POOL_ID --username $USERNAME | jq -r '.UserStatus'
# if FORCE_CHANGE_PASSWORD ... do stuff
USER_STATUS=`aws cognito-idp  admin-get-user --user-pool-id $USER_POOL_ID --username $USERNAME`


# Create a user:
aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $USERNAME --temporary-password $TEMP_PASSWORD

# Administratively auth as user
SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$TEMP_PASSWORD | jq -r ".Session"`

aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$DESIRED_PASSWORD,USERNAME=$USERNAME,userAttributes.name=$USERNAME --session $SESSION_KEY

````
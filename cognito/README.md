# Create Cognito Users


### Set the desired identity:
```
# Fill in values for your environment:
USER_POOL_ID=
APP_CLIENT_ID=
USERNAME=
EMAIL=
CURRENT_PASSWORD=
DESIRED_PASSWORD=
BOT_URL=
```

### To Sign Up new users:
```
aws cognito-idp sign-up --client-id $APP_CLIENT_ID \
 --username $USERNAME --password $DESIRED_PASSWORD \
 --user-attributes Name=name,Value=$USERNAME Name=email,Value=$EMAIL

aws cognito-idp admin-confirm-sign-up \
  --user-pool-id $USER_POOL_ID \
  --username $USERNAME
```

### To Confirm user accounts in FORCE_CHANGE_PASSWORD state, e.g. created from AWS Console.
```
# initiate auth on behalf of the user, get the session key

aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$CURRENT_PASSWORD

SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$CURRENT_PASSWORD | jq -r ".Session"`

# set user password

aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$DESIRED_PASSWORD,USERNAME=$USERNAME,userAttributes.name=$USERNAME --session $SESSION_KEY
```
### To authenticate as user:

```
# response format is JWT Bearer token. 
aws cognito-idp initiate-auth --client-id $APP_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$DESIRED_PASSWORD

# Try again, get the Id Token:
OAUTH_ID_TOKEN=`aws cognito-idp initiate-auth --client-id $APP_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$DESIRED_PASSWORD | jq -r ".AuthenticationResult.IdToken"`
```

#### AUTH against APIGW...
Call API methods that are configured with a user pool authorizer, and supply the unexpired token in the Authorization header or another header of your choosing.
https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-invoke-api-integrated-with-cognito-user-pool.html

#### POST to flowers bot endpoint:
curl -X POST -H "content-type: application/json" -H "Authorization: $OAUTH_ID_TOKEN"  --data '{ "intent":"我想订花", "userid":"bar"}' $BOT_URL; echo

### Misc Cognito commands. messing around.
```
aws cognito-idp describe-user-pool-client \
--user-pool-id $USER_POOL_ID \
--client-id $APP_CLIENT_ID
```


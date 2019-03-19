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

### Sign Up new users:
```
aws cognito-idp sign-up --client-id $APP_CLIENT_ID \
 --username $USERNAME --password $DESIRED_PASSWORD \
 --user-attributes Name=name,Value=$USERNAME Name=email,Value=$EMAIL

aws cognito-idp admin-confirm-sign-up \
  --user-pool-id $USER_POOL_ID \
  --username $USERNAME
```

#### Confirm user accounts in FORCE_CHANGE_PASSWORD state, 

This happens when users are initially created created, e.g from AWS Console.

Enable User Pool client settings. Go to:
```General settings -> App clients -> Details``` 
check the following: 
* ```Enable sign-in API for server-based authentication (ADMIN_NO_SRP_AUTH)```
* ```Enable username-password (non-SRP) flow for app-based authentication (USER_PASSWORD_AUTH)```


1. Initiate auth on behalf of the user, get the session key

Get a session key by authenticating administratively with the user temp password: 
SESSION_KEY=`aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$CURRENT_PASSWORD | jq -r ".Session"`

2. set user password
```
aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$DESIRED_PASSWORD,USERNAME=$USERNAME,userAttributes.name=$USERNAME --session $SESSION_KEY
```

3. Now Authenticate normally and get the OAUTH_ID_TOKEN:

Response format is JWT Bearer token. Get the Id Token:
OAUTH_ID_TOKEN=`aws cognito-idp initiate-auth --client-id $APP_CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$DESIRED_PASSWORD | jq -r ".AuthenticationResult.IdToken"`
```

#### POST to flowers bot endpoint:

Note use of Authorization header

```
curl -X POST -H "content-type: application/json" -H "Authorization: $OAUTH_ID_TOKEN"  --data '{ "intent":"我想订花", "userid":"bar"}' $BOT_URL; echo
```

### Misc Cognito commands. messing around.
```
aws cognito-idp describe-user-pool-client \
--user-pool-id $USER_POOL_ID \
--client-id $APP_CLIENT_ID
```


### MISC

 TODO: test whether need to add missing "I want to order flowers"


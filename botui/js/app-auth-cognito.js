// Get anonymous creds (unused, for illustration only)
AWS.config.region = config.region; 
AWS.config.credentials = new AWS.CognitoIdentityCredentials(
	{IdentityPoolId: config.identity_pool_id});

// Auth as a Cognito User, hardcoded for demo.
var authenticationData = {
    Username : config.test_user_name,
    Password : config.test_user_cred
};

var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

var poolData = { UserPoolId : config.user_pool_id,
    ClientId : config.user_pool_client_id
};
var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
var userData = {
    Username : config.test_user_name,
    Pool : userPool
};

var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function (result) {
    	console.log("Successfully authenticated cognito user")
        window.sessionStorage.setItem("idToken", result.idToken.jwtToken);
        console.log("Acquired session idToken: " + window.sessionStorage.getItem("idToken"))
        window.sessionStorage.setItem("cognitoUser", cognitoUser);
        window.sessionStorage.setItem("cognitoUsername", authenticationData.Username);
    },
    onFailure: function(err) {
        console.log(err);
    }
});


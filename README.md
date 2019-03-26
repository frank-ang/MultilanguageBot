# Multilanguage Chatbot

The Multilanguage Lex Bot example demonstrates a pattern to enable AWS customers to configure multilanguage conversational bot experiences across the 21 languages supported by Amazon Translate, overcoming the current US English monolingual limitation of Amazon Lex. 

The solution deploys a tranlation layer in front of the example Order Flowers Amazon Lex bot. This simple pattern provides a way for Amazon Lex bots to converse in all 21 languages supported by Amazon Translate. 

## Design

![Multilanguage Chatbot architecture](doc/architecture.png) 

The environment is defined in a SAM template: [MultilanguageBot.yaml](). 

TODO: split up into multiple CFN templates:
* ./MultilanguageBot.yaml
* cognito/cognito-cfn.yaml
* TODO/website.yaml
* TODO/pipeline.yaml
  ** TODO: codebuild with environment variables.

The solution is a nïeve implementation. Perhaps someone with a linguistics background might be able to identify potential edge cases of semantic mistranslations. Perhaps some Mechanical Turk testing could verify the quality of the bot by human native speaker testers (TODO potential enhancement).

### User Experience

A sample [BotUI](https://botui.org/) user interface is provided. The following illustrates the bot contextually switching between 2 different languages in response to user input. In this example, the front-end switches between Chinese (Simplified) and Bahasa Indonesia, mediating with the Lex back-end which remains limited to US English. To users, the effect is the bot appears to be multilingual.

![Mixing Chinese and Indonesian in session](doc/botui-session.png) 

### Cross-origin resource sharing (CORS)

The CORS browser security restriction arises from the fact that the S3 website endpoint and API Gateway endpoint have different DNS domain names.

To get around this, and to avoid fiddling with configuring CORS on API Gateway and Lambda, the approach used in this solution utilizes a common CloudFront distribution in front of both the S3 website and the API Gateway endpoint. 

Have not investigated what is the way for CloudFormation to setup CORS on API GW Regional Endpoint.

## Installation

#### 1. Create a Lex Bot: 
 * Create the default "OrderFlowers" example using a blueprint. [https://docs.aws.amazon.com/lex/latest/dg/gs-bp-create-bot.html]()

### 2. Create Cognito resources

Create the Cognito stack. This is a standalone stack, and Cognito resources would be referenced cross-stack from the Bot stack. 

Steps:

* create Cognito stack [cognito/cognito-cfn.yaml]()
* create Cognito user [cognito/README.md]()

Identity systems are shared across apps, so its possible to use an existing Cognito stack, you probably need to edit the Bot Cloudformation template to resolve any broken references. 


### 3. Create Multilanguage API resources

Create the main Bot stack. This has dependencies on the Cognito stack and makes cross-stack resource references, instead of stack nesting.

The Bot stack creates a BotTranslator Lambda function and API Gateway endpoint. IAM permissions are setup to permit calls to Comprehend, Translate, and Lex. 

SAM template: [MultilanguageBot.yaml]()

Package SAM template into a CloudFormation template, then Deploy the stack:

E.g.
```
# Change these paramters:
COGNITO_STACK_NAME=CognitoTestStack03
S3_BUCKET=sandbox01-demo-iad

sam package --template-file MultilanguageBot.yaml --s3-bucket $S3_BUCKET --output-template-file ./samOutput.yaml.gitignore

aws cloudformation deploy --capabilities CAPABILITY_IAM --template-file ./samOutput.yaml.gitignore --parameter-overrides "CognitoStackName=$COGNITO_STACK_NAME" --stack-name BotTestStack03

```

### 4. Web stack

This is the S3 website hosting the botui.js web client, with AuthN via Cognito. Upload of new S3 content performed by CodePipeline + CodeBuild.

Access the webpage from CloudFront.

TODO: add more details and create the child CFN stacks.

## API Testing

Request format:
```
{
  "intent": LOCALIZED_MULTILANGUAGE_TEXT,
  "userid": USER_ID
}
```

E.g.
```
{
  "intent": "Je souhaite acheter des fleurs",
  "userid": "user01"
}
```



### Example response

```
{
  "local_language": "zh",
  "en_response": "What type of flowers would you like to order?",
  "en_message": "I want to order flowers",
  "local_message": "我想订花",
  "local_response": "您想订购哪种类型的花?"
}
```

### Example confirmation of order :

```
{
  "confirmation": {
    "slots": {
      "PickupDate": "2018-10-26",
      "PickupTime": "09:00",
      "FlowerType": "Rose"
    },
    "dialogState": "ReadyForFulfillment",
    "intentName": "OrderFlowers",
    "ResponseMetadata": {
      "RetryAttempts": 0,
      "HTTPStatusCode": 200,
      "RequestId": "6edd92d4-d76a-11e8-bd4d-5f59a84f1d81",
      "HTTPHeaders": {
        "date": "Wed, 24 Oct 2018 08:54:36 GMT",
        "x-amzn-requestid": "6edd92d4-d76a-11e8-bd4d-5f59a84f1d81",
        "content-length": "243",
        "content-type": "application/json",
        "connection": "keep-alive"
      }
    }
  }
}
```

## Contributing
 
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
 

## License

The MIT License (MIT)

Copyright (c) 2019 Frank Ang

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Get your Chat Bot to support multi-languages

## Customer Challenge
Customers would like multi-language support in ChatBots, especially local languages in the local regions (Malay, Chinese, Thai). However, Lex currently supports only English.

## Build Synopsis
Combine Amazon Translate, Comprehend and Lex to build a Chat Bot that supports multi-languages.

## Setup steps.
1. Create the default OrderFlowers example Lex bot. 
2. Create a BotTranslator Lambda function with the code provided, with IAM permissions for Comprehend, Translate, and Lex. 
3. Start testing!

## Interface

* Request format:
```
{
  "intent": LOCALIZED_MULTILANGUAGE_TEXT,
  "userid": USER_ID
}
```

* Sample response:
```
{
  "local_language": "zh",
  "en_response": "What type of flowers would you like to order?",
  "en_message": "I want to order flowers",
  "local_message": "我想订花",
  "local_response": "您想订购哪种类型的花?"
}
```

* Confirmation response:
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
}```
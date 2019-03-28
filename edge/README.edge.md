## Create the web stack


```
aws cloudformation deploy --capabilities CAPABILITY_IAM \
--template-file ./cloudfront-website.yaml  \
--parameter-overrides "DomainName=$REPLACE_ME" \
--parameter-overrides "FullDomainName=$REPLACE_ME" \
--parameter-overrides "AcmCertificateArn=$REPLACE_ME" \
--stack-name $REPLACE_ME
```

E.g. 

```
aws cloudformation deploy --capabilities CAPABILITY_IAM \
--template-file ./edge-site.yaml  \
--parameter-overrides "DomainName=sandbox01.demolab.host" \
 "FullDomainName=bot07.sandbox01.demolab.host" \
 "AcmCertificateArn=arn:aws:acm:us-east-1:331780945983:certificate/77dfe72c-f644-4b70-b974-9b31d8c145c1" \
 "BotApiEndpoint=https://5q5qjlic60.execute-api.us-east-1.amazonaws.com/PROD/MultilanguageBot" \
--stack-name BotWebsite07
```

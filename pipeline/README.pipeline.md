# Pipeline for Multilanguage Chatbot

## Deploy Pipeline stack


```
aws cloudformation deploy --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --template-file ./pipeline.yaml \
 --parameter-overrides \
 "GitHubRepo=MultilanguageBot"  \
 "GitHubBranch=cross-ref-stacks" \
 "GitHubToken=CHANGEME" \
 "GitHubUser=frank-ang" \
 "WebsiteBucket=bot03.sandbox01.demolab.host" \
 "IdentityPoolId=SOMETHING_HARDCODED" \
--stack-name BotPipeline02
```
For GitHubToken, this is the OAuth token. Go to https://github.com/settings/tokens 



## To cleanup:

1. First delete all files in the S3 artifacts bucket. 
e.g. 
```
aws s3 rm s3://stackname-artifactbucket-foo --recursive
```

2. Delete the cloudformation stack.
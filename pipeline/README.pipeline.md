# Pipeline for Multilanguage Chatbot

## Deploy Pipeline stack


```
aws cloudformation deploy --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --template-file ./pipeline.yaml \
 --parameter-overrides \
 "GitHubRepo=MultilanguageBot"  \
 "GitHubBranch=cross-ref-stacks" \
 "GitHubToken=CHANGEME" \
 "GitHubUser=frank-ang" \
--stack-name BotPipeline00
```
For GitHubToken, this is the OAuth token. Go to https://github.com/settings/tokens
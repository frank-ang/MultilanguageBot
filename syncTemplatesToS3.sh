# syncTemplatesToS3.sh
# Syncs Cloudformation templates to the S3 bucket to permit top-level template to reference nested stacks 


aws s3 cp ./MultilanguageApi.yaml s3://multilanguage-bot/ --acl public-read 
aws s3 cp ./MultilanguageBotStack.yaml s3://multilanguage-bot/ --acl public-read 
aws s3 cp ./cognito/cognito-cfn.yaml s3://multilanguage-bot/cognito/ --acl public-read 
aws s3 cp ./edge/edge-site.yaml s3://multilanguage-bot/edge/ --acl public-read 
aws s3 cp ./pipeline/pipeline.yaml s3://multilanguage-bot/pipeline/ --acl public-read 

# syncTemplatesToS3.sh
# Syncs Cloudformation templates to the S3 bucket to permit top-level template to reference nested stacks 


aws s3 cp ./MultilanguageApi.yaml s3://multilanguage-bot/ --acl public-read 
aws s3 cp ./MultilanguageBotStack.yaml s3://multilanguage-bot/ --acl public-read 
aws s3 cp ./cloudformation/cognito.yaml s3://multilanguage-bot/cloudformation/ --acl public-read 
aws s3 cp ./cloudformation/edge-site.yaml s3://multilanguage-bot/cloudformation/ --acl public-read 
aws s3 cp ./cloudformation/pipeline.yaml s3://multilanguage-bot/cloudformation/ --acl public-read 

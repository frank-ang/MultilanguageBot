# syncTemplatesToS3.sh
# Syncs Cloudformation templates to the S3 bucket to permit top-level template to reference nested stacks 

aws s3 cp ./multilanguage-bot-stack.yaml s3://multilanguage-bot/ --acl public-read 
aws s3 sync ./cloudformation/ s3://multilanguage-bot/cloudformation/ --acl public-read 

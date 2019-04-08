#!/bin/bash
set -ev
echo "Creating cognito user, checking for required environment variables..."
# Check for required Environment Variables:
echo "$USER_POOL_ID"
echo "$USER_POOL_CLIENT_ID"
echo "$TEST_USER_SECRET_ID"
echo "$TEST_USER_NAME"
echo "$TEST_USER_CRED"

echo "completed"
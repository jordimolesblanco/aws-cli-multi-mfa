#!/bin/bash

# first we get our identity
echo "We start by checking if credentials are working ..."
identity=$(aws sts get-caller-identity --profile default)
username=$(echo -- "$identity" | sed -n 's!.*"arn:aws:iam::.*:user/\(.*\)".*!\1!p')

# oops, I cannot find user
if [ -z "$username" ]
then
  echo "Sorry, I cannot connect to the API with current credentials. Error:
$identity" >&2
  exit 255
else
  echo "Connection successful!"
fi

# great, user found!
echo You are: $username >&2

# now let's find our mfa device
mfa=$(aws iam list-mfa-devices --user-name "$username" --profile default)
device=$(echo -- "$mfa" | sed -n 's!.*"SerialNumber": "\(.*\)".*!\1!p')
if [ -z "$device" ]
then
  echo "Cannot find any MFA device for you. Please enable MFA in the AWS Console or see error:
$mfa" >&2
  exit 255
else
  echo "MFA device found and enabled!"
fi

# let's ask the user for the current MFA code
echo -n "Enter your MFA code now: " >&2
read -s code

# let's generate the temporary codes
echo "Generating temporary keys ..."
tokens=$(aws sts get-session-token --serial-number "$device" --token-code $code --profile default)
secret=$(echo -- "$tokens" | sed -n 's!.*"SecretAccessKey": "\(.*\)".*!\1!p')
session=$(echo -- "$tokens" | sed -n 's!.*"SessionToken": "\(.*\)".*!\1!p')
access=$(echo -- "$tokens" | sed -n 's!.*"AccessKeyId": "\(.*\)".*!\1!p')
expire=$(echo -- "$tokens" | sed -n 's!.*"Expiration": "\(.*\)".*!\1!p')

# oops, something went wrong and we failed to get tha codes
if [ -z "$secret" -o -z "$session" -o -z "$access" ]
then
  echo "Unable to get temporary credentials. See error:
$tokens" >&2
  exit 255
else
  echo "Temporary credentials generated successfully!"
fi

echo 'Removing old mfa setting'
sed -ie '/\[mfa\]/,$d' ~/.aws/credentials

echo 'Pushing new mfa token, key, id to credentials'
echo "[mfa]" >> ~/.aws/credentials
echo AWS_SESSION_TOKEN=$session >> ~/.aws/credentials
echo AWS_SECRET_ACCESS_KEY=$secret >> ~/.aws/credentials
echo AWS_ACCESS_KEY_ID=$access >> ~/.aws/credentials

echo Keys valid until $expire >&2

# What is this?

This is just a set of steps that will help you use `awscli` tool across accounts with MFA.

# Installing and Configuring AWSCLI

## Install/Upgrade the tool

If you don't have `awscli` yet or are using a version that is a few months old, install the latest following these official documents:

Linux | https://docs.aws.amazon.com/cli/latest/userguide/install-linux-python.html

Mac | https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html

Common issues with installation can be found in their official Github repository:
https://github.com/aws/aws-cli

**_It's very important to use the latest versions to get all the functionality you would see in the console and also to avoid facing bugs._**

## Configure your environment

* If not created yet (or lost the key), generate a new AWS access key in the AWS Console.

* If ~/.aws folder doesn't exist yet in your machine (usually because you just installed the tool), run `aws configure` and type random values for all fields (just to create the folder and files with the right permissions)

* Now empty the content of these 2 files

```
cd ~/.aws 
: > config
: > credentials
```

* Now copy the content of the `config` file in this repository to your local ~/.aws/config. Adapt it with the details of all the accounts you have.

* Next edit your local `~/.aws/credentials` file and set your key as generated in the AWS Console.

It should look like this, just replace the XXXXXXX and YYYYYYY values:

```python
[default]
aws_access_key_id = XXXXXXX
aws_secret_access_key = YYYYYYY
```

* Then place `aws-creds.sh` script that you will find in the repository to your machine and make it executable. It doesn't really matter where you place it, but it makes it easier to find if you copy it along with the other AWS stuff.

`chmod +x aws-creds.sh`

* To make it easier to find or run, you can create a shell alias with some short name such as `aws-mfa`

* Now run the script. It will ask you to enter the MFA code but you won't see it as you type it, the code is hidden.

If successful, it will show you the time the credentials will expire. You need to run this at least once a day.

## Test it

**_Before you do anything else you need to validate your configuration_**

The simplest way is to list the S3 buckets in the default account (without indicating profile).

Just run `aws s3 ls`

## Notes

* Just like when you are using the AWS Console, sessions expire. If you are not able to access resources, you need to run the `aws-creds.sh` script again. In most situations you will have to run this only once a day (sessions last for 8-12 hours). Some times, however, it will log you out and you will need to run it again, **_but you do not need to run this every time you need to run a command_**.

* The `aws-creds.sh` script generates credentials that allow you to run commands in all accounts. It doesn't work like the web interface where you "switch" to a different account. Instead, you have to specify the profile you are using to run the command every time.

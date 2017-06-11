#!/bin/sh

# 
# Usage: ./setup_cloud.sh deploy
# 	Sets up the cloud services and provisions the device certificates for AIDoorLock demo.
# Usage: ./setup_cloud.sh teardown
# 	Tears down the cloud services that have been previously set up by setup_cloud.sh start

# Change this to your desired region. Make sure that the following services
# are available in the region of your choice: Polly, Lex, Rekognition, IoT, Lambda, S3, SNS, CloudWatch and DynamoDB
HOST_REGION="us-east-1"

# Give a name to the S3 bucket which will be created. S3 bucket name rules apply.
BUCKET_FOR_IMAGES="aidoorlock-images"

# Name of the DynamoDB table that is created for this demo
GUEST_INFO_TABLE_NAME="aidoorlockguests"

# A phone number to receive passcode via SMS, posing as guest
GUEST_PHONE_NUMBER="+6588580447"

# Name of the Thing
THING_NAME="AIDoorLock"


# CHECK PREREQUISITES
function check_prerequisites () {
	# Python
	command -v python -V > /dev/null 2>&1 || { echo "Python was not detected. Aborting." >&2; exit 1; }
	echo "python detected"

	# AWS CLI
	command -v aws --version > /dev/null 2>&1 || { echo "AWS CLI was not detected. Aborting." >&2; exit 1; }
	echo "aws cli detected"

	# NODE JS
	command -v node --version > /dev/null 2>&1 || { echo "Node JS was not detected. Aborting." >&2; exit 1; }
	echo "node js detected"

	# SERVERLESS FRAMEWORK
	command -v serverless --version > /dev/null 2>&1 || { echo "Serverless Framework was not detected. Aborting." >&2; exit 1; }
	echo "serverless framework detected"
}

case "$1" in
	deploy)
		# Check prerequisites
		check_prerequisites

		# Generate configuration file for serverless
		if [ ! -d ".build" ]; then
		    mkdir .build
		fi
		echo "generating cloud configuration file (.build/cloud_config.yml)"
		cp cloud_config.yml .build/cloud_config.yml
		ACCOUNT_ID=`aws sts get-caller-identity --output text --query 'Account'`
		sed -i -e "s/ACCOUNT_ID/$ACCOUNT_ID/g" .build/cloud_config.yml
		sed -i -e "s/HOST_REGION/$HOST_REGION/g" .build/cloud_config.yml
		sed -i -e "s/BUCKET_FOR_IMAGES/$BUCKET_FOR_IMAGES/g" .build/cloud_config.yml
		sed -i -e "s/GUEST_INFO_TABLE_NAME/$GUEST_INFO_TABLE_NAME/g" .build/cloud_config.yml
		sed -i -e "s/THING_NAME/$THING_NAME/g" .build/cloud_config.yml
		echo "generating seed data file (.build/seed_data.json)"
		cp seed_data.json .build/seed_data.json
		sed -i -e "s/GUEST_PHONE_NUMBER/$GUEST_PHONE_NUMBER/g" .build/seed_data.json
		echo $THING_NAME > .build/thing_name.txt
		echo $HOST_REGION > .build/host_region.txt

		# Deploy serverless package
		echo "deploying serverless package to cloud"
		serverless deploy -v || { echo "Deployment failed." >&2; exit 1; }

		# Create item in $GUEST_INFO_TABLE_NAME with default seed data
		echo "seeding dynamodb with initial data"
		aws --region $HOST_REGION dynamodb put-item --table-name $GUEST_INFO_TABLE_NAME --item file://.build/seed_data.json  || { echo "Data initialisation failed." >&2; exit 1; }

		# provision device identities
		aws --output text --region $HOST_REGION iot create-keys-and-certificate --set-as-active --certificate-pem-outfile certs/certificate.pem.crt --public-key-outfile certs/public.pem.key --private-key-outfile certs/private.pem.key --query 'certificateArn' > .build/cert_arn.txt  || { echo "Failed to provision device certificate." >&2; exit 1; }
		aws --region $HOST_REGION iot attach-principal-policy --policy-name $THING_NAME"_Policy" --principal `cat .build/cert_arn.txt` || { echo "Failed to attach policy to certificate." >&2; exit 1; }
		aws --region $HOST_REGION iot attach-thing-principal --thing-name $THING_NAME --principal `cat .build/cert_arn.txt` || { echo "Failed to attach certificate to thing." >&2; exit 1; }

		echo "cloud deployment completed, now you can run ./setup_thing.sh"
		;;
	teardown)
		# Check prerequisites
		check_prerequisites

		# Verify existence of .build directory and its contents
		if [ ! -f ".build/cloud_config.yml" ]; then
			echo "Config not found. Aborting."
		fi

		# delete device identities
		aws --region $HOST_REGION iot detach-thing-principal --thing-name $THING_NAME --principal `cat .build/cert_arn.txt` || { echo "Failed to detach certificate from thing." >&2; exit 1; }
		aws --region $HOST_REGION iot detach-principal-policy --policy-name $THING_NAME"_Policy" --principal `cat .build/cert_arn.txt` || { echo "Failed to detach policy from certificate." >&2; exit 1; }
		CERT_ID=$(cat .build/cert_arn.txt | sed 's/.*cert\///')
		aws --output text --region $HOST_REGION iot update-certificate --certificate-id $CERT_ID --new-status "INACTIVE" || { echo "Failed to make certificate INACTIVE." >&2; exit 1; }
		aws --output text --region $HOST_REGION iot delete-certificate --certificate-id $CERT_ID || { echo "Failed to delete certificate." >&2; exit 1; }

		# Empty the S3 bucket
		echo "emptying the S3 bucket: $BUCKET_FOR_IMAGES"
		aws --region $HOST_REGION s3 rm --recursive s3://$BUCKET_FOR_IMAGES || { echo "Failed to remove files from S3 bucket $BUCKET_FOR_IMAGES." >&2; exit 1; }

		# Remove cloud stack
		echo "removing serverless stack from cloud"
		serverless remove || { echo "Failed." >&2; exit 1; }

		echo "deleting cloud configuration files (.build/*)"
		rm -rf .build/

		echo "cloud teardown completed, end of script"
		;;
	*)
		echo "Usage: $0 {deploy|teardown}"
		exit 1
esac


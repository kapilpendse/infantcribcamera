#!/bin/sh

# Sets up the AIDoorLock 'thing'. For the thing to work, 'cloud' side functionality must also be set up. Run 'setup_cloud.sh' to do that.
# Usage: ./setup_thing.sh

REKOGNITION_REGION="us-east-1"
LEX_REGION="us-east-1"
POLLY_REGION="us-west-2"
AWS_IOT_MQTT_HOST="yodayoda.iot.ap-southeast-1.amazonaws.com"
AWS_IOT_MQTT_PORT="8883"
AWS_IOT_MQTT_CLIENT_ID="ai-doorlock-$RANDOM"
AWS_IOT_THING_NAME="AIDoorLock"
AWS_IOT_THING_CERTIFICATE="yadayada-certificate.pem.crt"
AWS_IOT_THING_PRIVATE_KEY="yadayada-private.pem.key"

### CHECK PREREQUISITES ###

# Python
command -v python -V > /dev/null 2>&1 || { echo "Python was not detected. Aborting." >&2; exit 1; }
echo "python detected"

# AWS CLI
command -v aws --version > /dev/null 2>&1 || { echo "AWS CLI was not detected. Aborting." >&2; exit 1; }
echo "aws cli detected"

# AWS IOT parameter configuration and files
if [ -z "$AWS_IOT_MQTT_HOST" ]; then
    echo "Please set AWS_IOT_MQTT_HOST at the top of this script."
    exit 1
else
    echo "AWS_IOT_MQTT_HOST checked"
fi
if [ -z "$AWS_IOT_MQTT_CLIENT_ID" ]; then
    echo "Please set AWS_IOT_MQTT_CLIENT_ID at the top of this script."
    exit 1
else
    echo "AWS_IOT_MQTT_CLIENT_ID checked"
fi
if [ -z "$AWS_IOT_THING_CERTIFICATE" ]; then
    echo "Please set AWS_IOT_THING_CERTIFICATE at the top of this script."
    exit 1
else
    echo "AWS_IOT_THING_CERTIFICATE checked"
fi
if [ -z "$AWS_IOT_THING_PRIVATE_KEY" ]; then
    echo "Please set AWS_IOT_THING_PRIVATE_KEY at the top of this script."
    exit 1
else
    echo "AWS_IOT_THING_PRIVATE_KEY checked"
fi

# Check if this repo is cloned inside the AWS IoT Device SDK source code
if [[ $PWD != *'aws-iot-device-sdk-embedded-C-2.1.1/samples/linux/aidoorlock' ]]; then
    echo "Not inside AWS IoT Device SDK for C 2.1.1. See 'How do I get set up?' section in README."
    exit 1
else
    echo "AWS IoT Device SDK found."
fi

# Check if mbedTLS source code is present. Required for the compilation to succeed.
if [ ! -f ../../../external_libs/mbedTLS/Makefile ]; then
    echo "mbedTLS source code not found. See 'How do I get set up?' section in README."
    exit 1
else
    echo "mbedTLS found."
fi

# Check if device certificate and private key are present in 'certs' folder
if [ ! -f certs/$AWS_IOT_THING_CERTIFICATE ]; then
    echo "$AWS_IOT_THING_CERTIFICATE is not present in the 'certs' folder. Aborting."
    exit 1
else
    echo "$AWS_IOT_THING_CERTIFICATE found"
fi
if [ ! -f certs/$AWS_IOT_THING_PRIVATE_KEY ]; then
    echo "$AWS_IOT_THING_PRIVATE_KEY is not present in the 'certs' folder. Aborting."
    exit 1
else
    echo "$AWS_IOT_THING_PRIVATE_KEY found"
fi

# If OS is Mac, check for brew
if [[ $OSTYPE == darwin* ]]; then
    command -v brew -v > /dev/null 2>&1 || { echo "brew was not detected. Aborting." >&2; exit 1; }
    echo "OS is mac, brew detected"
fi

### SETUP THING ###

# Install mpg123
echo "checking for mpg123"
if [[ $OSTYPE == "linux-gnu" ]]; then
    command -v mpg123 --version > /dev/null 2>&1 || { echo "mpg123 not detected, installing." >&2; sudo apt-get install mpg123; }
elif [[ $OSTYPE == darwin* ]]; then
    command -v mpg123 --version > /dev/null 2>&1 || { echo "mpg123 not detected, installing." >&2; brew install mpg123; }
fi

echo "checking for SoX"
# Install SoX for the command 'rec'
if [[ $OSTYPE == "linux-gnu" ]]; then
    command -v rec --version > /dev/null 2>&1 || { echo "SoX not detected, installing." >&2; sudo apt-get install sox; }
elif [[ $OSTYPE == darwin* ]]; then
    command -v rec --version > /dev/null 2>&1 || { echo "SoX not detected, installing." >&2; brew install sox; }
fi

# Install fswebcam (for USB webcam on Linux) or imagesnap (for FaceTime camera on Mac)
if [[ $OSTYPE == "linux-gnu" ]]; then
    echo "checking for fswebcam"
    command -v fswebcam --version > /dev/null 2>&1 || { echo "fswebcam not detected, installing." >&2; sudo apt-get install fswebcam; }
elif [[ $OSTYPE == darwin* ]]; then
    echo "checking for imagesnap"
    command -v imagesnap -h > /dev/null 2>&1 || { echo "imagesnap not detected, installing." >&2; brew install imagesnap; }
fi

# Setup AWS IOT params in aws_iot_config.h
echo "generating file with IoT settings"
cp aws_iot_config_template.h aws_iot_config.h
sed -i -e "s/PLACEHOLDER_MQTT_HOST/$AWS_IOT_MQTT_HOST/g" aws_iot_config.h
sed -i -e "s/PLACEHOLDER_MQTT_PORT/$AWS_IOT_MQTT_PORT/g" aws_iot_config.h
sed -i -e "s/PLACEHOLDER_MQTT_CLIENT_ID/$AWS_IOT_MQTT_CLIENT_ID/g" aws_iot_config.h
sed -i -e "s/PLACEHOLDER_THING_NAME/$AWS_IOT_THING_NAME/g" aws_iot_config.h
sed -i -e "s/PLACEHOLDER_MQTT_CERT_FILENAME/$AWS_IOT_THING_CERTIFICATE/g" aws_iot_config.h
sed -i -e "s/PLACEHOLDER_MQTT_PRIV_KEY_FILENAME/$AWS_IOT_THING_PRIVATE_KEY/g" aws_iot_config.h

# Build aidoorlock
echo "building aidoorlock"
make
echo "end of script"

#!/bin/bash

HOST_REGION=$1
S3_BUCKET_NAME=$2
LOCAL_IMAGE_FILE_PATH="camera_captures/image.jpg"
UPLOADED_FILE_NAME='image.jpg'

echo "Watching $(pwd)/camera_captures/"

fswatch -0 -e .DS_Store camera_captures/ | while read -d "" event; \
do \
	echo ${event}
	LOCAL_IMAGE_FILE_PATH=${event}
	# upload the image to S3 bucket
	echo "uploading to $HOST_REGION $S3_BUCKET_NAME $UPLOADED_FILE_NAME from $LOCAL_IMAGE_FILE_PATH"
	python `pwd`/scripts/s3uploader.py "$HOST_REGION" "$S3_BUCKET_NAME" "$LOCAL_IMAGE_FILE_PATH" "$UPLOADED_FILE_NAME"
	echo "upload complete"
done

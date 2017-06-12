#!/usr/bin/python
import os
import boto3
import sys

# This script uploads a file to an S3 bucket in the specified region with the specified file name
# Usage: s3uploader.py HOST_REGION S3_BUCKET_NAME LOCAL_FILE_PATH UPLOADED_FILE_NAME
# 

HOST_REGION = sys.argv[1]
S3_BUCKET_NAME = sys.argv[2]
# LOCAL_FILE_PATH = 'camera_captures/image.jpg'
LOCAL_FILE_PATH = sys.argv[3]
UPLOADED_FILE_NAME = sys.argv[4]

# s3 = boto3.resource('s3')
s3 = boto3.client('s3',region_name=HOST_REGION)

data = open(LOCAL_FILE_PATH, 'rb')
# s3.Bucket(S3_BUCKET_NAME).put_object(Key='image.jpg', Body=data)
s3.put_object(Key=UPLOADED_FILE_NAME, Bucket=S3_BUCKET_NAME, Body=data)
# os.remove(LOCAL_FILE_PATH)


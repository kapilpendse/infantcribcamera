#!/usr/bin/python
import os
import boto3

S3BUCKET = 'raspi3locksuseast1'
IMAGE_FILE = '/home/pi/camera_captures/image.jpg'

s3 = boto3.resource('s3')

data = open(IMAGE_FILE, 'rb')
s3.Bucket(S3BUCKET).put_object(Key='image.jpg', Body=data)
os.remove(IMAGE_FILE)


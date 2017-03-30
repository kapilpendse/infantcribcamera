#!/bin/bash

# this script takes 2 arguments: text for voice prompt asking for the passcode and text for voice prompt
# after listening the passcode

# voice prompt before taking photo
python `pwd`/scripts/speak.py "$1"

# Capture image using camera
# raspistill -w 800 -h 600 -q 70 -t 2 -o "/home/pi/camera_captures/image.jpg"

# voice prompt after taking photo
python `pwd`/scripts/speak.py "$2"

# python `pwd`/scripts/s3uploader.py


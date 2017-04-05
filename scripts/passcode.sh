#!/bin/bash

# this script takes 2 arguments: text for voice prompt asking for the passcode and text for voice prompt
# after listening the passcode

# voice prompt asking for passcode
python `pwd`/scripts/speak.py "$1"

# record the spoken passcode
# raspistill -w 800 -h 600 -q 70 -t 2 -o "/home/pi/camera_captures/image.jpg"
rec /tmp/passcode.wav trim 0 0:00:05

# send the recorded audio clip to Lex for verification, and take appropriate action after verification
python `pwd`/scripts/verify_passcode.py /tmp/passcode.wav

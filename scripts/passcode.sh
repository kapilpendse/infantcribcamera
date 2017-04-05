#!/bin/bash

# this script takes 2 arguments: text for voice prompt asking for the passcode and text for voice prompt
# after listening the passcode

# voice prompt asking for passcode
python `pwd`/scripts/speak.py "$1"

# record the spoken passcode
rec -c 1 -r 16000 -e signed -b 16 /tmp/audiorec.wav trim 0 0:00:05

# send the recorded audio clip to Lex for verification, and take appropriate action after verification
python `pwd`/scripts/verify_passcode.py /tmp/audiorec.wav

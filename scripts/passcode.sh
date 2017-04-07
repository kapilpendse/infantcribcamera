#!/bin/bash

# this script takes 2 arguments: text for voice prompt asking for the passcode and text for voice prompt
# after listening the passcode

passcode=$1
askPrompt=$2
allowPrompt=$3
denyPrompt=$4

# voice prompt asking for passcode
python `pwd`/scripts/speak.py "$askPrompt"

# record the spoken passcode
rec -c 1 -r 16000 -e signed -b 16 /tmp/audiorec.wav trim 0 0:00:05

# send the recorded audio clip to Lex for verification, and take appropriate action after verification
python `pwd`/scripts/verify_passcode.py /tmp/audiorec.wav "$passcode" "$allowPrompt" "$denyPrompt"


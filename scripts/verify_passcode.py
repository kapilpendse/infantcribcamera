import io
import sys
import boto3
import os

audioFileName = sys.argv[1]
passcode = sys.argv[2]
allowPrompt = sys.argv[3]
denyPrompt = sys.argv[4]
HOST_REGION = sys.argv[5]

lex = boto3.client('lex-runtime', region_name=HOST_REGION)
print("got lex runtime")

try:
	#initiate the lex bot converstation
	response = lex.post_text(
		botName='AIDoorLockEchoBot',
		botAlias='Dev',
		userId='1234',
		inputText='Echo my passcode'
	)
	print(response)

	#send the spoken passcode for interpretation
	audioFile = io.open(audioFileName, "rb")
	response = lex.post_content(
		botName='AIDoorLockEchoBot',
		botAlias='Dev',
		userId='1234',
		contentType='audio/l16; rate=16000; channels=1',
		accept='text/plain; charset=utf-8',
		inputStream=audioFile
	)
	print(response)
	userSpokenPasscode = str(response['slots']['Passcode'])
	print(str(response['slots']['Passcode']))
	if(userSpokenPasscode == passcode):
		os.system('python scripts/speak.py "' + allowPrompt + '"')
	else:
		os.system('python scripts/speak.py "' + denyPrompt + '"')

	#end the conversation with lex bot
	response = lex.post_text(
		botName='AIDoorLockEchoBot',
		botAlias='Dev',
		userId='1234',
		inputText='yes'
	)
	print(response)

except:
	print("There was an exception")
	print(sys.exc_info())

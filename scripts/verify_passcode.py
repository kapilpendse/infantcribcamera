import sys
import boto3

lex = boto3.client('lex-runtime', region_name='us-east-1')
print("got lex runtime")

try:
	#initiate the lex bot converstation
	response = lex.post_text(
		botName='EchoBot',
		botAlias='Dev',
		userId='747',
		inputText='Echo my passcode'
	)
	print(response)

	#send the spoken passcode for interpretation
	response = lex.post_text(
		botName='EchoBot',
		botAlias='Dev',
		userId='747',
		inputText='1234'
	)
	print(response)

	#end the conversation with lex bot
	response = lex.post_text(
		botName='EchoBot',
		botAlias='Dev',
		userId='747',
		inputText='yes'
	)
	print(response)

except:
	print("There was an exception")
	print(sys.exc_info()[0])

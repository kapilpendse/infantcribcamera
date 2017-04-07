import sys
import gzip
from StringIO import StringIO
import json
import boto3

iotData = boto3.client('iot-data', region_name='ap-southeast-1')
guestInfoTable = boto3.resource('dynamodb').Table('LocksGuestInfo')

def sendCommandToLock(command):
    iotResponse = iotData.publish(
        topic='locks/commands',
        payload=command
    )
    print(iotResponse)
    return 0

def lambda_handler(event, context):
    try:
        #capture the CloudWatch log data
        logData = str(event['awslogs']['data'])
        # print(logData)
        
        #decode and unzip the log data
        decodedData = gzip.GzipFile(fileobj=StringIO(logData.decode('base64','strict'))).read()
        print(decodedData)
        
        #convert the log data from JSON into a dictionary
        jsonData = json.loads(decodedData)
        jsonMessageDetails = json.loads(jsonData['logEvents'][0]['message'])
        print(jsonMessageDetails)
        messageId = jsonMessageDetails['notification']['messageId']
        deliveryStatus = jsonMessageDetails['status']
        print("Message ID: " + messageId)
        print("Delivery Status: " + deliveryStatus)
        guestInfoItem = guestInfoTable.get_item(
            Key={
                'GuestId': 1
            }
        )
        print("MessageId: " + str(guestInfoItem['Item']['MessageId']))
        if(str(guestInfoItem['Item']['MessageId']) == messageId and deliveryStatus == "SUCCESS"):
            sendCommandToLock('ASK SECRET')
        else:
            sendCommandToLock('ASK SECRET')
            # sendCommandToLock('SMS FAILED')
    except:
        print "Unexpected error:", sys.exc_info()[0]
    return "done"

import sys
import boto3
import json
import random
# from botocore.errorfactory import InvalidParameterException

rekognition = boto3.client('rekognition', region_name='us-east-1')
iotData = boto3.client('iot-data', region_name='ap-southeast-1')

def sendCommandToLock(command):
    iotResponse = iotData.publish(
        topic='locks/commands',
        payload=command
    )
    print(iotResponse)
    return 0

def generateNewPasscode():
    return str(random.randint(1000, 9999))

def sendPasscodeToGuest(passcode):
    try:
        sns = boto3.client('sns')
        phonenumber = '+6588580447'
        sns.publish(PhoneNumber = phonenumber, Message=passcode)
    except AuthorizationErrorException:
        print("AuthorizationErrorException: does this lambda function's IAM role have access to SNS to send SMS?")
    return 0

def updatePasscode():
    newPasscode = generateNewPasscode()
    print("New passcode is " + newPasscode)
    sendPasscodeToGuest(newPasscode)
    sendCommandToLock('UPDATE PASSCODE ' + newPasscode)
    return 0

def lambda_handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]
    print("Key: " + key)

    try:
        rekResponse = rekognition.compare_faces(
            SourceImage={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            },
            TargetImage={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': 'enrolled_guest.jpg'
                }
            },
            SimilarityThreshold=80.0
        )
        print(rekResponse)
    
        print("Bucket: " + bucket)
        print("Key: " + key)

        try:
            similarity = rekResponse["FaceMatches"][0]["Similarity"]
            print("Similarity: " + str(similarity))
    
            if(similarity > 80):
                print("It is a match!")
                updatePasscode()
                sendCommandToLock('ASK SECRET')
            else:
                print("Face does not match!")
                sendCommandToLock('FACIAL VERIFICATION FAILED')
        except IndexError:
            print("Face does not match")
            sendCommandToLock('FACIAL VERIFICATION FAILED')
    except:
        print("Unexpected exception - likely InvalidParameterException in Rekognition (service bug?), should retry")
        print "Unexpected error:", sys.exc_info()[0]
        sendCommandToLock('FACIAL VERIFICATION FAILED')

    return "done"
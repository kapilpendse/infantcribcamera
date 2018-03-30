import sys
import boto3
import json
import os
# from botocore.errorfactory import InvalidParameterException

rekognition = boto3.client('rekognition')
iotData = boto3.client('iot-data')
parentInfoTableName = os.environ['PARENTS_TABLE_NAME']
parentInfoTable = boto3.resource('dynamodb').Table(parentInfoTableName)

def sendCommandToLock(command):
    iotResponse = iotData.publish(
        topic='infantcribcamera/commands',
        payload=command
    )
    print(iotResponse)
    return 0

def notifyParent():
    message = "Attention! Your child is sleeping in an unsafe position."
    try:
        sns = boto3.client('sns')
        parentInfoItem = parentInfoTable.get_item(
            Key={
                'ParentId': 1
            }
        )
        phonenumber = parentInfoItem['Item']['PhoneNumber']
        response = sns.publish(PhoneNumber = phonenumber, Message=message)
        print("SMS notification sent to parent, message ID is " + response['MessageId'])
        response = parentInfoTable.update_item(
            Key={
                'ParentId': 1
            },
            UpdateExpression="set MessageId = :m",
            ExpressionAttributeValues={
                ":m": response['MessageId']
            },
            ReturnValues='UPDATED_NEW'
        )
    except AuthorizationErrorException:
        print("AuthorizationErrorException: does this lambda function's IAM role have access to SNS to send SMS?")
    return 0

def detectHuman(bucket, key):
    humanLabels = [
        "Asleep",
        "Human",
        "People",
        "Person",
        "Baby",
        "Child",
        "Kid",
        "Newborn",
        "Face"
    ]

    print("Calling detect_labels")
    rekResponse = rekognition.detect_labels(
        Image={
            'S3Object': {
                'Bucket': bucket,
                'Name': key
            }
        },
        MinConfidence=50
    )
    print(rekResponse)

    labels = rekResponse["Labels"]
    for l in labels:
        print("Label: " + l["Name"])
        if l["Name"] in humanLabels:
            print("Human detected");
            return True;

    print("Human not detected");
    return False

def detectFace(bucket, key):
    print("Calling detect_faces")
    rekResponse = rekognition.detect_faces(
        Image={
            'S3Object': {
                'Bucket': bucket,
                'Name': key
            }
        }
    )
    print(rekResponse)

    faces = rekResponse["FaceDetails"]
    numFaces = len(faces)
    if numFaces > 0:
        print("Face(s) detected: " + str(numFaces))
        return True;

    print("Face(s) not detected")
    return False;


def lambda_handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]
    print("Key: " + key)

    try:
        print("Bucket: " + bucket)
        print("Key: " + key)
        humanDetected = detectHuman(bucket, key)
        if humanDetected:
            faceDetected = detectFace(bucket, key)
            if faceDetected:
                sendCommandToLock('CHILD IS SAFE')
            else:
                sendCommandToLock('CHILD IS UNSAFE')
                notifyParent()
        else:
            sendCommandToLock('CRIB IS EMPTY')
    except:
        print("Unexpected exception - likely InvalidParameterException in Rekognition (service bug?), should retry")
        print "Unexpected error:", sys.exc_info()[0]
        sendCommandToLock('ERROR')

    return "done"
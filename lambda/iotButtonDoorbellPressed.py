import boto3

iotData = boto3.client('iot-data')

def sendCommandToLock(command):
    iotResponse = iotData.publish(
        topic='locks/commands',
        payload=command
    )
    print(iotResponse)
    return 0

def lambda_handler(event, context):
    sendCommandToLock('CAPTURE PHOTO')
    return 'doorbell pressed, face recognition activated'

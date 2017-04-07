# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification.

### What is this repository for? ###

* This demo uses AWS services such as Rekognition, IoT, Lambda, S3, Polly and Lex. The parts of this demo are to be run on Raspberry Pi 3.

### Prerequisites ###

* Raspberry Pi 3 with PiCam 2
* AWS IoT SDK for C, and it's prereq openssl
* mpg123 (sudo apt-get install mpg123)
* Python
* SoX (rec)
* AWS IAM account API key and secret set up correctly on the Raspberry Pi ~/.aws/. The IAM account must have access to the following services: S3, Polly and Lex.
* AWS default region set up to point to 'us-east-1' on the Raspberry Pi ~/.aws/. Currently Rekognition & Lex are available only in us-east-1.
* IoT device certificates
* Configure audio defaults on the RPi to use USB audio dongle
* AWS SNS configured for sending out SMS, with default spending limit increased to suitable value

### How do I get set up? ###

* Setup of USB audio dongle
vi ~/.asoundrc and replace the contents with below 2 lines:
pcm.!default plughw:Device
ctl.!default plughw:Device

* Lambda Functions
    * Set up iotButtonDoorbellPressed.py in Singapore region, to be triggered by the AWS IoT button.
    * Set up verifyFace.py in N. Virginia region (because it needs to access Rekognition), to be triggered by image.jpg upload to S3 bucket 'raspi3locksuseast1'. This upload is done by the aidoorlock program from Rasbperry Pi.
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* kapilpen@

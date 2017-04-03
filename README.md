# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification.

### What is this repository for? ###

* This demo uses AWS services such as Rekognition, IoT, Lambda, S3, Polly and Lex. The parts of this demo are to be run on Raspberry Pi 3.

### Prerequisites ###

* Raspberry Pi 3 with PiCam 2
* AWS IoT SDK for C, and it's prereq openssl
* mpg123
* Python
* SoX (rec)
* AWS IAM account API key and secret set up correctly on the Raspberry Pi ~/.aws/. The IAM account must have access to the following services: S3, Polly and Lex.
* IoT device certificates
* Configure audio defaults on the RPi to use USB audio dongle

### How do I get set up? ###

* Setup of USB audio dongle
vi ~/.asoundrc and replace the contents with below 2 lines:
pcm.!default plughw:Device
ctl.!default plughw:Device

* Configuration
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

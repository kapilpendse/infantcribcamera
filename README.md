# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification.

### What is this repository for? ###

* This demo uses AWS services such as Rekognition, IoT, Lambda, S3, Polly and Lex. The parts of this demo are to be run on Raspberry Pi 3.

### Prerequisites ###

#### Common prerequisites for all platforms
* Python & AWS CLI
* AWS default region set up to point to 'us-east-1' on the Raspberry Pi ~/.aws/. Currently Rekognition & Lex are available only in us-east-1.
* AWS SNS configured in your AWS account for sending out SMS, with default spending limit increased to suitable value

#### To run on Raspberry Pi 3 with PiCam 2
* Raspberry Pi 3 with PiCam 2
* Raspbian
* raspistill (comes with Raspbian)
* AWS IoT Device SDK for C, with mbedTLS (https://github.com/aws/aws-iot-device-sdk-embedded-C)
* IoT device certificates
* mpg123 (sudo apt-get install mpg123)
* SoX for 'rec' command (sudo apt-get install sox)
* Configure audio defaults on the RPi to use USB audio dongle (see 'Setup of USB audio dongle' below)

#### To run on Raspberry Pi 3 with USB webcam
* Raspberry Pi 3
* Raspbian
* Standard USB UVC type webcam
* fswebcam (sudo apt-get install fswebcam)
* AWS IoT Device SDK for C, with mbedTLS (https://github.com/aws/aws-iot-device-sdk-embedded-C)
* IoT device certificates
* mpg123 (sudo apt-get install mpg123)
* SoX for 'rec' command (sudo apt-get install sox)
* Configure audio defaults on the RPi to use USB audio dongle (see 'Setup of USB audio dongle' below)

#### To run on Mac OSX with built-in webcam
* AWS IoT Device SDK for C, with mbedTLS (https://github.com/aws/aws-iot-device-sdk-embedded-C)
* IoT device certificates
* brew (https://brew.sh/)
* mpg123 (sudo brew install mpg123)
* SoX for 'rec' command (sudo brew install sox)
* imagesnap for running on MAC OSX (sudo brew install imagesnap)

### How do I get set up? ###

#### Setup on MAC OSX
1. Download the AWS IoT Device SDK 2.1.1 source code (https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
2. cd aws-iot-device-sdk-embedded-C-2.1.1/external_libs/mbedTLS/
3. Download mbedTLS source code from https://github.com/ARMmbed/mbedtls/releases/tag/mbedtls-2.1.1 and extract all files in this folder. When done right, this folder should have several files including a Makefile.
4. cd ../../samples/linux
5. Clone 'aidoorlock' in this directory
6. Verify that ./aidoorlock/certs contains 'root-ca.pem'
7. Copy your device certificate, private key and public key to ./aidoorlock/certs/
8. Open 'aws_iot_config.h' and change 'AWS_IOT_MQTT_HOST', 'AWS_IOT_CERTIFICATE_FILENAME' and 'AWS_IOT_PRIVATE_KEY_FILENAME' to values appropriate for your device and certificates.
9. cd aidoorlock
10. make - this command will build the mbedTLS library, the AWS IoT Device SDK and then the application 'aidoorlock'
11. ./aidoorlock
12. If all is well, the program should output it's own IP addresses (eth0 & wlan0) to the AWS IoT topic 'locks/ip' and speak out the words 'Doorlock is ready' from the laptop's speakers.

#### Setup of USB audio dongle
vi ~/.asoundrc and replace the contents with below 2 lines:
pcm.!default plughw:Device
ctl.!default plughw:Device

#### Lambda Functions
    * Set up iotButtonDoorbellPressed.py in Singapore region, to be triggered by the AWS IoT button.
    * Set up verifyFace.py in N. Virginia region (because it needs to access Rekognition), to be triggered by image.jpg upload to S3 bucket 'raspi3locksuseast1'. This upload is done by the aidoorlock program from Rasbperry Pi.

#### Autostart on bootup
    * To auto run the application on Raspberry Pi bootup, create links under /etc/network/if-up.d/ and /etc/network/if-down.d/ as below:
    * sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifup.sh /etc/network/if-up.d/aidoorlock
    * sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifdown.sh /etc/network/if-down.d/aidoorlock

### Who do I talk to? ###

* kapilpen@

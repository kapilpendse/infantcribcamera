# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification.

### What is this repository for? ###

* This demo uses AWS services such as Rekognition, IoT, Lambda, S3, Polly and Lex. The parts of this demo are to be run on Raspberry Pi 3.

### Prerequisites ###

#### Common prerequisites for all platforms
* Python & AWS CLI
* AWS IoT Device SDK 2.1.1 (https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
* mbedTLS 2.1.1 library which is a dependency of the AWS IoT Device SDK 2.1.1
* IoT device certificates
* AWS SNS configured in your AWS account for sending out SMS, with default spending limit increased to suitable value

#### To run on Raspberry Pi 3 with PiCam 2
* Raspberry Pi 3 with PiCam 2
* Raspbian
* raspistill (comes with Raspbian)

#### To run on Raspberry Pi 3 with USB webcam
* Raspberry Pi 3
* Raspbian
* Standard USB UVC type webcam
* fswebcam (sudo apt-get install fswebcam)
* mpg123 (sudo apt-get install mpg123)
* SoX for 'rec' command (sudo apt-get install sox)
* Configure audio defaults on the RPi to use USB audio dongle (see 'Setup of USB audio dongle' below)

#### To run on Mac OSX with built-in webcam
* brew (https://brew.sh/)
* mpg123 (sudo brew install mpg123)
* SoX for 'rec' command (sudo brew install sox)
* imagesnap for running on MAC OSX (sudo brew install imagesnap)

### How do I get set up? ###

#### Setup on MAC OSX
1. Download the AWS IoT Device SDK 2.1.1 source code (https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
2. Download and extract the mbedTLS source code inside 'aws-iot-device-sdk-embedded-C-2.1.1/external_libs/mbedTLS/' directory. Here's the download link: https://github.com/ARMmbed/mbedtls/releases/tag/mbedtls-2.1.1 After extraction, the 'mbedTLS' directory should have several files including a Makefile.
3. Open a terminal and go to "aws-iot-device-sdk-embedded-C-2.1.1/samples/linux"
4. Clone 'aidoorlock' in this directory (git clone https://kapilpendse@bitbucket.org/kapilpendse/aidoorlock.git)
5. Copy your device certificate and private key to ./aidoorlock/certs/
6. In terminal, go to 'aidoorlock' directory and run 'setup_thing.sh' script.
7. If the script completes without any errors, run ./aidoorlock
8. If all is well, the program should output it's own IP addresses (eth0 & wlan0) to the AWS IoT topic 'locks/ip' and you should hear the words 'Doorlock is ready' from your computer's speakers.

#### Setup of USB audio dongle on Raspberry Pi
* vi ~/.asoundrc and replace the contents with below 2 lines:
* pcm.!default plughw:Device
* ctl.!default plughw:Device

#### Lambda Functions to be set up in AWS account
* Set up iotButtonDoorbellPressed.py in Singapore region, to be triggered by the AWS IoT button.
* Set up verifyFace.py in N. Virginia region (because it needs to access Rekognition), to be triggered by image.jpg upload to S3 bucket 'raspi3locksuseast1'. This upload is done by the aidoorlock program from Rasbperry Pi.

#### Autostart on bootup of Raspberry Pi
* To auto run the application on Raspberry Pi bootup, create links under /etc/network/if-up.d/ and /etc/network/if-down.d/ as below:
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifup.sh /etc/network/if-up.d/aidoorlock
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifdown.sh /etc/network/if-down.d/aidoorlock

### Who do I talk to? ###

* kapilpen@

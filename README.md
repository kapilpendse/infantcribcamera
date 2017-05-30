# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification. It uses AWS services such as IoT, Rekognition, Polly, Lex, Lambda, S3 and SNS.

There are 2 components to this demo - the 'aidoorlock' program that runs on a thing and a bunch of cloud services that runs on AWS cloud. This demo supports the following platforms as 'thing' - Raspberry Pi 3 with Raspbian, any Linux system with Debian/Ubuntu, Mac with OSX.

Most of the setup process is automated, however some manual setup is still required. Refer to the "How do I get set up?" section below for step by step instructions.

## Prerequisites ##

### Common prerequisites for all platforms
* Python & AWS CLI
* [AWS IoT Device SDK 2.1.1](https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
* [mbedTLS 2.1.1](https://github.com/ARMmbed/mbedtls/releases/tag/mbedtls-2.1.1) library which is a dependency of the AWS IoT Device SDK 2.1.1
* IoT device certificates, generated under your AWS account. [to be automated]
* AWS SNS configured in your AWS account for sending out SMS, with default spending limit increased to suitable value

### To run on Raspberry Pi 3
* Raspberry Pi 3 with PiCam 2 or USB webcam
* Raspbian
* raspistill (comes with Raspbian, used only if using PiCam)
* A USB audio dongle for connecting a speaker as well as a microphone. [Here's an example.](http://www.lazada.sg/easybuy-new-pc-laptop-usb-2-3d-virtual-kx3p-71-channel-audio-soundcard-adapter-9019448.html)

### To run on Mac OSX with built-in webcam
* [brew](https://brew.sh/)

### How do I get set up? ###

1. Setup cloud services by running the setup_cloud.sh script in a terminal.
2. Download the AWS IoT Device SDK 2.1.1 [source code](https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
3. Download and extract the [mbedTLS source code](https://github.com/ARMmbed/mbedtls/releases/tag/mbedtls-2.1.1) inside 'aws-iot-device-sdk-embedded-C-2.1.1/external_libs/mbedTLS/' directory. After extraction, the 'mbedTLS' directory should have several files including a Makefile.
4. Open a terminal and go to "aws-iot-device-sdk-embedded-C-2.1.1/samples/linux"
5. Clone 'aidoorlock' in this directory (`git clone https://kapilpendse@bitbucket.org/kapilpendse/aidoorlock.git`)
6. Copy your device certificate and private key to ./aidoorlock/certs/ [to be automated]
7. In terminal, go to 'aidoorlock' directory and run 'setup_thing.sh' script.
8. If the script completes without any errors, run ./aidoorlock
9. If all is well, the program should output it's own IP addresses (eth0 & wlan0) to the AWS IoT topic 'locks/ip' and you should hear the words 'Doorlock is ready' from your computer's speakers.

### Setup of USB audio dongle on Raspberry Pi
* vi ~/.asoundrc and replace the contents with below 2 lines:
* pcm.!default plughw:Device
* ctl.!default plughw:Device

### Lambda Functions to be set up in AWS account
* Set up iotButtonDoorbellPressed.py in Singapore region, to be triggered by the AWS IoT button.
* Set up verifyFace.py in N. Virginia region (because it needs to access Rekognition), to be triggered by image.jpg upload to S3 bucket 'raspi3locksuseast1'. This upload is done by the aidoorlock program from Rasbperry Pi.

### Autostart on bootup of Raspberry Pi
* To auto run the application on Raspberry Pi bootup, create links under /etc/network/if-up.d/ and /etc/network/if-down.d/ as below:
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifup.sh /etc/network/if-up.d/aidoorlock
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifdown.sh /etc/network/if-down.d/aidoorlock

### Who do I talk to? ###

* kapilpen@amazon.com

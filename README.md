# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification. It uses AWS services such as IoT, Rekognition, Polly, Lex, Lambda, S3 and SNS.

There are 2 components to this demo - the 'aidoorlock' program that runs on a thing and a bunch of cloud services that runs on AWS cloud. This demo supports the following platforms as 'thing' - Raspberry Pi 3 with Raspbian, any Linux system with Debian/Ubuntu, Mac with OSX.

Most of the setup process is automated, however some manual setup is still required. Refer to the "How do I get set up?" section below for step by step instructions.

## Prerequisites ##

### Common prerequisites for all platforms
* Python & [AWS CLI](https://aws.amazon.com/cli/)
* [AWS IoT Device SDK 2.1.1](https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
* [mbedTLS 2.1.1](https://github.com/ARMmbed/mbedtls/archive/mbedtls-2.1.1.tar.gz) library which is a dependency of the AWS IoT Device SDK 2.1.1
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

Open a bash terminal and type in the following commands:
~~~~
mkdir ~/ai-iot-demo
cd ~/ai-iot-demo
tar xzf DOWNLOADED_FILES/aws-iot-device-sdk-embedded-C-2.1.1.tar.gz
cd aws-iot-device-sdk-embedded-C-2.1.1/external_libs/mbedTLS
tar xzf DOWNLOADED_FILES/mbedtls-mbedtls-2.1.1.tar.gz --strip-components 1
cd ../../samples/linux
git clone https://kapilpendse@bitbucket.org/kapilpendse/aidoorlock.git
./setup_cloud.sh
./setup_thing.sh
~~~~

If there are no errors, run `./aidoorlock`, the program should output the IP addresses of your computer (eth0 & wlan0) to STDOUT and publish to the AWS IoT topic 'locks/ip' and you should hear the words 'Doorlock is ready' from your computer's speakers.

### Setup of USB audio dongle on Raspberry Pi
Edit ~/.asoundrc and replace its contents with following 2 lines:
~~~~
pcm.!default plughw:Device
ctl.!default plughw:Device
~~~~

### Lambda Functions to be set up in AWS account
* Set up iotButtonDoorbellPressed.py in Singapore region, to be triggered by the AWS IoT button.
* Set up verifyFace.py in N. Virginia region (because it needs to access Rekognition), to be triggered by image.jpg upload to S3 bucket 'raspi3locksuseast1'. This upload is done by the aidoorlock program from Rasbperry Pi.

### Autostart on bootup of Raspberry Pi
* To auto run the application on Raspberry Pi bootup, create links under /etc/network/if-up.d/ and /etc/network/if-down.d/ as below:
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifup.sh /etc/network/if-up.d/aidoorlock
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifdown.sh /etc/network/if-down.d/aidoorlock

### Who do I talk to? ###

* kapilpen@amazon.com

# README #

This is a concept demo for a door lock equipped with AI capabilities such as voice interaction and facial verification. It uses AWS services such as IoT, Rekognition, Polly, Lex, Lambda, S3 and SNS.

There are 2 components to this demo - the 'aidoorlock' program that runs on a thing and a bunch of cloud services that runs on AWS cloud. This demo supports the following platforms as 'thing' - Raspberry Pi 3 with:
* Raspbian (setup scripts don't work, WIP)
* Debian/Ubuntu Linux (setup scripts don't work, WIP)
* Mac with macOS Sierra

Most of the setup process is automated, however some manual setup is still required. Refer to the "Setup Instructions" section below for step by step instructions.

## Prerequisites ##

### Common prerequisites for all platforms
* Python & [AWS CLI](https://aws.amazon.com/cli/)
* [AWS IoT Device SDK 2.1.1](https://github.com/aws/aws-iot-device-sdk-embedded-C/archive/v2.1.1.tar.gz)
* [mbedTLS 2.1.1](https://github.com/ARMmbed/mbedtls/archive/mbedtls-2.1.1.tar.gz) library which is a dependency of the AWS IoT Device SDK 2.1.1
* AWS SNS configured in your AWS account for sending out SMS, with default spending limit increased to suitable value

### Prerequisites for Raspberry Pi 3
* Raspberry Pi 3 board with PiCam 2 or USB webcam
* Raspbian
* raspistill (comes with Raspbian, used only if using PiCam)
* A USB audio sound card adaptor/dongle for connecting a speaker and a microphone. [Here's an example.](http://www.lazada.sg/easybuy-new-pc-laptop-usb-2-3d-virtual-kx3p-71-channel-audio-soundcard-adapter-9019448.html)

### Prerequisites for Mac OSX with built-in webcam
* [brew](https://brew.sh/)

## Setup Instructions ##

Open a bash terminal and type in the following commands:
~~~~
mkdir ~/ai-iot-demo
cd ~/ai-iot-demo
tar xzf DOWNLOADED_FILES/aws-iot-device-sdk-embedded-C-2.1.1.tar.gz
cd aws-iot-device-sdk-embedded-C-2.1.1/external_libs/mbedTLS
tar xzf DOWNLOADED_FILES/mbedtls-mbedtls-2.1.1.tar.gz --strip-components 1
cd ../../samples/linux
git clone https://kapilpendse@bitbucket.org/kapilpendse/aidoorlock.git
cd aidoorlock
./setup_cloud.sh deploy
./setup_thing.sh
~~~~

If there are no errors, run `./aidoorlock`, the program should output the IP addresses of your computer (eth0 & wlan0) to STDOUT (along with a bunch of debug messages) and also publish the IP addresses to the AWS IoT topic 'locks/ip'; Additionally, you should hear the words 'Doorlock is ready' from your computer's speakers.

### Setup of USB audio dongle on Raspberry Pi
Edit ~/.asoundrc and replace its contents with following 2 lines:
~~~~
pcm.!default plughw:Device
ctl.!default plughw:Device
~~~~

### Autostart on bootup of Raspberry Pi
* To auto run the application on Raspberry Pi bootup, create links under /etc/network/if-up.d/ and /etc/network/if-down.d/ as below:
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifup.sh /etc/network/if-up.d/aidoorlock
* sudo ln -s /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock/ifdown.sh /etc/network/if-down.d/aidoorlock

## Demo Suggestions ##
The easiest way to run this demo is on a Mac with macOS Sierra. This is easy, portable and you don't need to setup a Raspberry Pi with all its accessories. Simply follow the setup instructions above, run `aidoorlock` and then open "doorbell.html" in a browser.

If you are feeling more adventurous, you can use an AWS IoT Button instead of the virtual doorbell (doorbell.html). You will have to configure an AWS IoT Button in your account, setup the Lambda function 'iotButtonDoorbellPressed.py', and add a rule for the button so that it invokes the 'iotButtonDoorbellPressed.py' Lambda function.

### Telling the story ###
Here's an outline of the story I tell the audience: If you have ever used Airbnb, you will know that the first thing you do when you book an apartment is to coordinate with the host about your arrival time, so that the host can be there to give you the apartment keys. It is quite common that travel plans get disrupted due to flight delays and what not. When this happens, the host has only 2 miserable options: wait endlessly for the guest to arrive (because often the guest would not be reachable by phone), or leave the apartment locked and wait for the guest to somehow call you when they arrive (a great way to earn bad rating from the guest).

We've solved this problem by using AWS services to create a smart door lock with a camera. The door lock takes a picture of the guest when they press the doorbell, and uses Amazon Rekognition to verify that the person at the door is the expected guest. It then sends a dynamically generated 4 digit passcode via SMS to the expected guest's registered phone number. This is 'multi factor authentication' (MFA). The doorbell does not have any keypad. Instead, it implements a VUI (voice user interface). A speaker speaks out instructions using the Amazon Polly service, and a microphone listens to what the guest speaks, and uses the Amazon Lex service to understand the spoken words. If the spoken words match the dynamically generated passcode, the speaker announces that the guest is welcome to enter, otherwise it scares the unexpected guest by saying that the police has been alerted ;-)

Behind the scenes, all of this interaction is stitched together by AWS IoT and AWS Lambda services, with a delicious dressing of S3, DynamoDB and SNS.

This demo focuses on highlighting the ease with which it is possible to solve real world problems using AWS services. The actual door lock hardware control is not implemented because that is a fairly straight-forward and well understood technology - just hook up the Raspberry Pi with a servo controlled lock. Another reason to leave that component out of scope for this demo is that we want this demo to be portable and easy to setup. Setting up specialised hardware like servos and locks is straight-forward, but not easy & portable.

## Troubleshooting ##
* If the `setup_cloud.sh` script fails during deployment with the error message `Unable to validate the following destination configurations`, do the following steps:
	* Login to your AWS web console, go to Cloud Formation page and delete the stack named 'aidoorlock-dev'. If this fails, delete again by this time choose to retain the S3 bucket 'aidoorlock-dev-serverlessdeployment-*'. Once the stack is deleted, delete the S3 bucket manually if it still exists.
	* On your Raspberry Pi or computer, run the `setup_cloud.sh` script again.
	* [This problem has been reported](https://github.com/serverless/serverless/issues/3038) by many users of the 'serverless' framework.
* OpenSSL version issue: On macOS Sierra, if you see the following error, run `brew install openssl`:

~~~
UnsupportedTLSVersionWarning: Currently installed openssl version: OpenSSL 0.9.8zh 14 Jan 2016 does not support TLS 1.2, which is required for use of iot-data. Please use python installed with openssl version 1.0.1 or higher.
~~~

* Contact me ;)

### Who do I talk to? ###
* Kapil Pendse (kapilpen@amazon.com)

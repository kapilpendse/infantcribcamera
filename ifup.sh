#!/bin/bash

cd /home/pi/deviceSDK/linux_mqtt_openssl/sample_apps/aidoorlock
echo "Starting AI Door Lock Daemon in 30 seconds" > /tmp/aidoorlock.log
sleep 30
su -c "./aidoorlock > /tmp/aidoorlock2.log &" -s /bin/sh pi
echo "Done" >> /tmp/aidoorlock.log


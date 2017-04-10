#!/bin/bash

echo "Stopping AI Door Lock Daemon" >> /tmp/aidoorlock.log
pkill aidoorlock >> /tmp/aidoorlock.log
echo "Done" >> /tmp/aidoorlock.log


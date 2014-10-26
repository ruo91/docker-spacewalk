#!/bin/bash
spacewalk-setup --disconnected --answer-file=/opt/answer.txt
sleep 5
spacewalk-service start
exit 0

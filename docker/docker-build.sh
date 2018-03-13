#!/usr/bin/env bash
# Check for a newer version of jenkins
docker pull jenkins/jenkins:alpine
# Now build the image.
docker build -t phiroict/ansible-jenkins:20180310 .

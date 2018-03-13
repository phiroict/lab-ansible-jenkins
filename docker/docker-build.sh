#!/usr/bin/env bash

# ## Get the latest version of jenkins
docker pull jenkins/jenkins:alpine
# ## Build the image.
docker build -t phiroict/ansible-jenkins:20180313 .

#!/usr/bin/env bash

# Delete the old container #############################################################################################
docker rm -f lab-redhat-ansible
# Create the jobs header we use for persist the jobs and configurations of jenkins,
# if it already exists, it does nothing.  ##############################################################################
docker volume create jobs
# Create the container, exports the ports and then runs it in the background. ##########################################
docker run \
  --name lab-redhat-ansible \
  -p 8080:8080 -p 50000:50000 \
  -v jobs:/var/jenkins_home \
  -d \
  phiroict/ansible-jenkins:20180304
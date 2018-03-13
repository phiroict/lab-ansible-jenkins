#!/usr/bin/env bash

# Delete the old container #############################################################################################
docker rm -f lab-redhat-ansible
# Create the jobs header we use for persist the jobs and configurations of jenkins,
# if it already exists, it does nothing.  ##############################################################################
docker volume create jobs
# Create the container, exports the ports and then runs it in the background. ##########################################
docker run \
  --name lab-redhat-ansible \
  -p 18080:8080 -p 50000:50000 \
  -v jobs:/var/jenkins_home \
  -d \
  phiroict/ansible-jenkins:20180313
# Copy the ssh key over to the box as the volume would overwrite it
docker exec -d lab-redhat-ansible mkdir -p /var/jenkins_home/.ssh/
docker cp /home/pr1438/.ssh/id_rsa_aws_proxy lab-redhat-ansible:/var/jenkins_home/.ssh/
docker cp /home/pr1438/.ssh/id_rsa_aws_proxy.pem lab-redhat-ansible:/var/jenkins_home/.ssh/
docker exec -d lab-redhat-ansible chmod 0400 /var/jenkins_home/.ssh/*

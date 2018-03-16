#!/usr/bin/env bash

# Delete the old container #############################################################################################
docker rm -f lab-redhat-ansible
# Create the jobs volume we use for persisting the jobs and configurations of jenkins, this is stored apart from the
# container and it will not be destroyed when the container is.
# if the volume already exists, it does nothing.  ######################################################################
docker volume create jobs
# Create the container, exports the ports and then run it in the background.
# We mount the jobs volume on the directory where jenkins stores its jobs, plugins and configuration ###################
docker run \
  --name lab-redhat-ansible \
  -p 8080:8080 -p 50000:50000 \
  -v jobs:/var/jenkins_home \
  -d \
  phiroict/ansible-jenkins:20180313
# Copy the ssh key over to the box as the volume would overwrite it
docker exec -d lab-redhat-ansible mkdir -p /var/jenkins_home/.ssh/
docker cp /home/pr1438/.ssh/id_rsa_aws_proxy lab-redhat-ansible:/var/jenkins_home/.ssh/
docker cp /home/pr1438/.ssh/id_rsa_aws_proxy.pem lab-redhat-ansible:/var/jenkins_home/.ssh/
docker exec -d lab-redhat-ansible chmod 0400 /var/jenkins_home/.ssh/*

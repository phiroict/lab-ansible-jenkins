#!/usr/bin/env bash

docker rm -f lab-redhat-ansible
docker volume create jobs
docker run \
  --name lab-redhat-ansible \
  -p 8080:8080 -p 50000:50000 \
  -v jobs:/var/jenkins_home \
  -d \
  phiroict/ansible-jenkins:20180304
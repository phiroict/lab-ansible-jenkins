FROM jenkins/jenkins:alpine

# ### Install ansible ##################################################################################################
USER root

RUN apk update
RUN apk add ansible

# ### Install the same folders as tower and copy over ssh keys #########################################################
USER root
RUN mkdir -p /var/lib/awx/.ssh

COPY artefacts/openstack.pem /var/lib/awx/.ssh/
RUN chown -R jenkins:jenkins /var/lib/awx/.ssh
RUN chmod 0400 /var/lib/awx/.ssh/openstack.pem

# ### Install the ssh config ###########################################################################################
USER jenkins

COPY artefacts/ssh.cfg /var/lib/awx/.ssh/ssh.cfg


# ### Switch to jenkins user ###########################################################################################
USER jenkins


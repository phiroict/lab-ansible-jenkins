FROM jenkins/jenkins:alpine

# ### Install ansible ##################################################################################################
USER root

RUN apk update
RUN apk add ansible sudo py-pip
RUN pip install boto boto3

# ### Install the same folders as tower and copy over ssh keys #########################################################
USER root
RUN mkdir -p /var/lib/awx/.ssh

COPY artefacts/openstack.pem /var/lib/awx/.ssh/
COPY artefacts/id_rsa_aws_proxy.pem /var/lib/awx/.ssh/id_rsa_aws_proxy
RUN chown -R jenkins:jenkins /var/lib/awx/.ssh
RUN chmod 0400 /var/lib/awx/.ssh/openstack.pem
RUN chmod 0400 /var/lib/awx/.ssh/id_rsa_aws_proxy

# ### Install the ssh config ###########################################################################################
USER jenkins

COPY artefacts/ssh.cfg /var/lib/awx/.ssh/ssh.cfg


# ### Switch to jenkins user ###########################################################################################
USER jenkins


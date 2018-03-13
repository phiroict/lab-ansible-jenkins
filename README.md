# Ansible lab with Jenkins

# Preface
This is a project based on the redhat advanced ansible training replacing Ansible tower, a paid enterprise project, by the Open Source Jenkins CI stack. 
Note, for now it only describes the Openstack QA part.


# Prereqs
* Access to an Open stack environment through a jumphost.
* AWS account allowing you to create infrastructure and deploy servers.
* Docker 17.09 or later.
* Ansible 2.4+ (For openstack support).
* Access to the advanced ansible course materials. 
* Access to the private key connecting you to the Openstack jumphost (Name it openstack.pem).
* Access to the advanced ansible course project.


# Set up

## Jenkins
* Get the openstack.pem key and put this in the docker/artefacts folder
* Install docker 
* Change the jenkins-ci/docker/artefacts/ssh.cfg project to point to your jump host
So in this case replace the _workstation-02d7.rhpds.opentlc.com_ string with your jumphost. (This is for openstack, aws does 
this differently)

```
Host workstation-02d7.rhpds.opentlc.com
  User cloud-user
  Hostname workstation-02d7.rhpds.opentlc.com
  ForwardAgent no
  Compression yes
  IdentityFile /var/lib/awx/.ssh/openstack.pem
  ServerAliveInterval 60

Host 10.10.10.*
  IdentityFile /var/lib/awx/.ssh/openstack.pem
  User cloud-user
  ProxyCommand ssh -F /var/lib/awx/.ssh/ssh.cfg workstation-02d7.rhpds.opentlc.com -W %h:%p

Host *
  StrictHostKeyChecking no
  IdentitiesOnly yes

```
* Run the docker/docker-build.sh script, this installs: 
  * Jenkins
  * Creates a volume for job persistence
  * Installs the key and ssh configuration. 
* Go to http://localhost:8080  
* Use
```bash
docker run -it lab-redhat-ansible bash
```  
To get to the initial password Jenkins asks you about.
* Accept the recommended plugins.
* Now, install the CloudBees Amazon Web Services Credentials plugin from the manage jenkins / Manage plugins menu. 

* Now get your AWS credentials and place these in the environment of the Jenkins run.   
  
## Jenkins jobs
  
See the jobs dir, you can copy these into the container by
```bash
docker cp jobs lab-redhat-ansible:/var/jenkins_home/
```
Note that you need to create the vault password and the aws credentials. 

  
## Jenkins pipelines
```groovy
pipeline {
    agent any
    stages {
        stage('Create QA servers') {
            steps {
                build 'QA-create-instances'
            }
        }
        stage('Install QA applications') {
            steps {
                build 'QA-install-apps'
            }
        }
        stage('Test QA application') {
            steps {
                build 'QA-smoke-test'
            }
        }
        stage('Delete QA servers') {
            steps {
                build 'QA-delete-instances'
            }
        }
    }
    post {
        failure {
          build 'QA-delete-instances'
        }
      }
}
```  

## Apps AWS
In the aws project we use a centos image not a redhat enterprise as we want to keep it open source so replace the 
redhat repos template by: 
```text
#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=addons
#baseurl=http://mirror.centos.org/centos/$releasever/addons/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1


#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=contrib
#baseurl=http://mirror.centos.org/centos/$releasever/contrib/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=2
```
 The epel repo has been installed 
# Ansible lab with Jenkins

# Preface
This is a project based on the redhat advanced ansible training replacing Ansible tower, a paid enterprise project, by the Open Source Jenkins CI stack. 
Note, this is about an Openstack project and a AWS project.

You basically need to have access to the course material or been at the training to make sense of this, however, the principles still count. 
As the course handles about ansible tower this handles the implementation with Jenkins which would be closer to what most projects use (And is
considerable cheaper.)
I build this after having great problems to get ansible tower working and wanted to have some solution that would prove the underlaying concepts 
before circling back to Ansible tower and try to get that to work. 


You need three repos for this: 
* https://github.com/phiroict/course-redhat-tower-os-3tier.git for the QA apps on Openshift
* https://github.com/phiroict/course-redhat-tower-aws-3tier.git for the production on AWS
* https://github.com/phiroict/DEFUNCT_course-redhat-ansible-lab-assignment.git The jenkins configuration, it is not as defunct as the name suggests. 
  * Use the lab-ansible-jenkins folder here. This has the docker definitions discussed below. 


# Prereqs
* Access to an Open stack environment through a jumphost (or configure it for direct access).
* AWS account allowing you to create infrastructure and deploy servers.
* Docker 17.09 or later.
* Ansible 2.4+ (For openstack support).
* Access to the advanced ansible course materials (You may make sense of it without it, good luck!). 
* Access to the private key connecting you to the Openstack jumphost (Name it openstack.pem).
* The private key you use for AWS instance ssh access. In this case rename it to id_rsa_aws_proxy.pem or change the name in the Dockerfile 
* Access to the advanced ansible course project.


# Set up

## Jenkins
### Openstack QA
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
* Run the ```docker/docker-build.sh``` script, this installs: 
  * Jenkins
  * Creates a volume for job persistence
  * Installs the key and ssh configuration. 
* Start the container with ```docker/docker-run.sh```
  * This creates the volume and starts the container.   
* Go to http://localhost:18080  
* Use
```bash
docker run -it lab-redhat-ansible bash
```  
To get to the initial password Jenkins asks you about by getting it with 
```docker exec -it lab-redhat-ansible bash```

* Accept the recommended plugins.
* Now, install the __Ansible__ and the __CloudBees Amazon Web Services Credentials__ plugin from the manage jenkins / Manage plugins menu. 
* Now get your AWS credentials and place these in the environment of the Jenkins run.   
* Store the ansible vault password as a secret type credential in the Credentials / jenkins menu option. 

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
 The epel repo has been installed so we do not need these. 
  
## Jenkins jobs
  
See the jobs dir, you can copy these into the container by
```bash
docker cp jobs lab-redhat-ansible:/var/jenkins_home/
```
after starting the container, you need to restart jenkins to let it detect the jobs. 
Note that you need to create the vault password and the aws credentials. Check each job of the correct vault and aws credentials are 
selected as that sometimes gets lost. 

  
## Jenkins pipelines
This pipeline glues the jobs together in a pipeline. Like Ansible Tower, you can do actions on failure. There are several ways of doing this, as the
pipeline is defined in Jenkins DSL, a subsection of Groovy, you can catch exceptions or just detect the error at the end and then execute the "on error" 
job. 

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
        stage('Create PROD instances') {
            steps {
                build 'PROD-create-instances'
            }
        }
        stage('Install PROD applications') {
            steps {
                build 'PROD-install-apps'
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


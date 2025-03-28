N26 Version ABIB-OYEBAMIJI-1.0- TSD

Target release	N26 Version 1.0
Epic	N26 Security App.
Document status	Completed
Document owner	Abib Oyebamiji
Product Owner	N26
Security Architect	Abib Oyebamiji
Cloud Engineer	Abib Oyebamiji

Background
The assignment focuses on securing a multi-tier application on AWS by implementing security controls while maintaining performance and scalability.
Business Problem
The company needs to ensure the highest level of security for its cloud infrastructure while optimizing network security, encryption, and monitoring.
Goals
The task involves designing a secure architecture, implementing Infrastructure as Code (IaC), and deploying security solutions for an AWS-based application.
Assumptions
The system consists of an application server tier and a backend database, requiring encryption, network security, and monitoring solutions for compliance and security enhancements



Important Components
Components	Setup By	Description
Terraform	HarshiCorp	Terraform enables infrastructure automation for provisioning, compliance, and management of any cloud, datacenter, and service.
RDS	AWS	For creating user profiles.
EC2	AWS	It is used for provides scalable computing capacity in the Amazon Web Services (AWS) Cloud.
Load Balancer	AWS	Load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.
Launch Template	AWS	A launch template contains the configuration information to launch an instance so that you do not have to specify them each time you launch an instance.
VPC	AWS	A virtual private cloud (VPC) is a secure, isolated private cloud hosted within a public cloud.
Route Table	AWS	The main purpose of a route table is to help routers make effective routing decisions. Whenever a packet is sent through a router to be forwarded to a host on another network, the router consults the routing table to find the IP address of the destination device and the best path to reach it.
Internet Gateway	AWS	An internet gateway enables resources in your public subnets (such as EC2 instances) to connect to the internet if the resource has a public IPv4 address or an IPv6 address.
Subnets	AWS	It is used to subdivide large networks into smaller, more efficient subnetworks.
Target Group	AWS	Target groups route requests to one or more registered targets, such as EC2 instances, using the protocol and port number specified.
NAT Gateway	AWS	A NAT gateway is a Network Address Translation (NAT) service. It is used to connect instances in a private subnet to services outside your VPC but external services cannot initiate a connection with those instances.
Auto Scaling Group	AWS	Autoscaling provides users with an automated approach to increase or decrease the compute, memory or networking resources they have allocated, as traffic spikes and use patterns demand.
Security Groups	AWS	A security group controls the traffic that is allowed to reach and leave the resources that it is associated with. 
NACLs	AWS	A network ACL (or NACL) controls traffic to or from a subnet according to a set of inbound and outbound rules.
Bastion Servers	AWS	A bastion host is a server whose purpose is to provide access to a private network from an external network, such as the Internet.
Route 53	AWS	A scalable DNS web service that routes end-user requests to AWS resources, domains, and applications globally. It also supports health checks and failover for high availability.
WAF	AWS	Protects web applications from common threats like SQL injection and XSS attacks. It filters, monitors, and blocks malicious traffic using customizable rules.


 
Improved Architecture Diagram 
 
Workflow / Process Flows / Architectural Diagrams
  
Repository Link:
https://github.com/abiboye1/N26-Assignment.git
Application Versioning:
N26 Version 1.0
Step by step guide
PLEASE READ AND FOLLOW THE STEPS BELOW:
This guide provides step-by-step instructions to deploy the provided Terraform code, which
provisions a scalable AWS infrastructure including a VPC (and its resources e.g. route tables, NACL etc.), RDS, Auto Scaling groups, a load balancer, WAF, Macie, GuardDuty and CloudTrail.

1.	AWS Account: Ensure you have an AWS account with the necessary permissions.
2.	Create a user in AWS IAM and attach the managed AdministratorAccess policy. Ensure that this user is provided with Access key and Secret key.
3.	In Git Bash, create a directory named terraform 
mkdir terraform
4.	Save your AWS credentials locally. 
vi ~/.aws/credentials 
•	Paste the Access and Secret key values you got from AWS IAM
[default]
aws_access_key_id = 
aws_secret_access_key =
5.	AWS CLI: Install and configure with credentials for the target AWS account.
aws configure
This will prompt you to input your credentials, (if you already saved your credentials as described in step 4 above, just push the enter key twice). 
6.	Run a git clone of the repository you are trying to access:
git clone https://github.com/abiboye1/N26-Assignment.git
7.	Change directory into the newly cloned directory
cd N26-Assignment
8.	You should be in the ‘main’ branch by default. As best practice, you may want to switch to a ‘dev’ branch.
git checkout -b dev
9.	To create a file to save your RDS credentials (db_password and db_username) locally, do the following:
vi tfvars.local
•	Press the ‘I’ key to do an insert. Then create the db_password and db_username variables with their values (Note: the values given below are just for illustration):
db_username = “n26_db”
db_password = "Pa$$w0rd”
•	Save and exit by doing this:
o	esc  :wq!
Note: To run your ‘terraform plan’ or ‘terraform apply’, you will be prompted to provide these credentials, starting with the password and then username.
code .    
•	This should open the VS Code, and you should see the tfvars.local as part of the Terraform files.
10.	Prior to deployment, make sure you have Terraform installed on your PC, if it’s not installed yet. 
choco install terraform -y
After installing, do a terraform -version (NOTE: This is strictly for Windows Users)
11.	Deploy using
terraform init
terraform apply -auto-approve
•	Note that terraform apply will prompt you for your database credentials. 

Testing the Deployment
Log into AWS to be sure that all resources have been successfully deployed)
-	Verify the following EC2 Instances were generated: Bastion EC2 Instances, App EC2 Instances, Web EC2 Instances were generated.
 
Check the Security Group, ALB, Target Group, WAF were generated
Security Groups 
ALB
 
Target
 
AWS WAF
 
 
-	Check that the VPC and associated resources were generated
VPC & Resources
     
 
CloudTrail
 

S3
 
 

Amazon Macie
 
 

GuardDuty
 
-	Grab the DNS of the ALB from the output, open a browsing window and paste the DNS in it.
•	You should see a welcome message, this indicates that the deployment was successful.
o	If the message does not pop up, check if the target group is healthy
o	Try in a private incognito window
-	To SSH into the Bastion server: 
•	Adjust the inbound rule in the Bastion server security group to allow port 22 traffic from your IP
•	Add a rule in the public subnet NACL to allow port 22 from your IP.












PART TWO
Deploying a new security agent or tool to every EC2 instance in the platform
•	The Python and the secrets manager script is part of the cloned script from Git initially, running the scripts above should have executed the latter script. Once terraform apply is completed, run the following: 
sudo yum update -y
sudo yum install python3 -y
sudo yum install python3-pip -y
pip3 install --upgrade pip
pip3 install boto3
pip3 install paramikopython3 terran.py
•	To confirm everything works, SSH into the instance:
ssh -i your-key.pem ec2-user@your-instance-ip
•	Check logs:
cat /var/log/cloud-init-output.log
•	Verify the agent is installed:
ps aux | grep agent

 


Secrets Manager
 

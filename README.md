# Automated Application URL Health Monitoring with Terraform, EC2 & SNS (100% IaC)

- You wanted to build an automated system that checks the health of a URL for every 15 mins and sends alerts if the service is down
- if app is down, it must send alert to slack,teams,etc...

```
TERRAFORM:
==========
sudo apt update -y

awscli:
-------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
                 
sudo apt install wget unzip
pwd
/home/ubuntu
mkdir terraform && cd terraform

cat <<EOF >>/home/ubuntu/terraform/terraform-install.sh
#!/bin/sh
cd /home/ubuntu/terraform
TER_VER=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | head -n 1 | cut -d '"' -f4)
TER_VER_CLEAN=${TER_VER#v}
wget https://releases.hashicorp.com/terraform/${TER_VER_CLEAN}/terraform_${TER_VER_CLEAN}_linux_amd64.zip
unzip terraform_${TER_VER_CLEAN}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
EOF

chmod 755 terraform-install.sh
bash terraform-install.sh
which terraform
terraform --version


To use an Amazon SNS topic to send Gmail notifications, you need to create an SNS topic and subscribe your desired email address to it, then publish a message to the topic. SNS will then deliver the message as an email to the subscribed address. 



root@ip-172-31-94-157 ec2-user]# sudo grep CRON /var/log/cron
May  4 15:54:13 ip-172-31-94-157 crond[3161]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 44% if used.)
May  4 15:54:13 ip-172-31-94-157 crond[3161]: (CRON) INFO (running with inotify support)
May  4 15:55:01 ip-172-31-94-157 CROND[3370]: (ec2-user) CMD (python3 /home/ec2-user/health_check.py)



root@ip-172-31-94-157 ec2-user]# pwd
/home/ec2-user
[root@ip-172-31-94-157 ec2-user]# ls
config.yaml  health_check.log  health_check.py

[root@ip-172-31-94-157 ec2-user]# cat health_check.log
2025-05-04 15:55:01,558 [INFO] Health check passed for https://www.google.com
2025-05-04 15:56:01,836 [INFO] Health check passed for https://www.google.com
2025-05-04 15:57:02,127 [INFO] Health check passed for https://www.google.com
2025-05-04 15:58:01,406 [INFO] Health check passed for https://www.google.com
2025-05-04 15:59:01,691 [INFO] Health check passed for https://www.google.com
```

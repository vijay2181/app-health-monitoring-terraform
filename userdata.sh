#!/bin/bash
yum update -y
yum install -y python3 curl -y
#pip3 install boto3 pyyaml requests
pip3 install urllib3==1.26.18 requests==2.31.0 boto3 pyyaml


# Write the config.yaml file
cat <<EOF > /home/ec2-user/config.yaml
${config_yaml}
EOF

# Write the health_check.py file
cat <<'EOF' > /home/ec2-user/health_check.py
${health_check_script}
EOF

# Create log file if it doesn't exist
touch /home/ec2-user/health_check.log
chown ec2-user:ec2-user /home/ec2-user/health_check.log
chmod 644 /home/ec2-user/health_check.log

# Set correct permissions for all files
chmod +x /home/ec2-user/health_check.py
chown ec2-user:ec2-user /home/ec2-user/*

# Add cron job
echo "* * * * * ec2-user python3 /home/ec2-user/health_check.py" > /etc/cron.d/health_check
chmod 644 /etc/cron.d/health_check

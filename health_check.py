import requests
import yaml
import boto3
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(
    filename='/home/ec2-user/health_check.log',
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
)

def check_health(url):
    try:
        response = requests.get(url, timeout=5)
        return response.status_code == 200
    except requests.RequestException as e:
        logging.error(f"Error while checking health: {e}")
        return False

def main():
    # Read the config.yaml
    try:
        with open('/home/ec2-user/config.yaml', 'r') as file:
            config = yaml.safe_load(file)
    except Exception as e:
        logging.error(f"Failed to load config.yaml: {e}")
        return

    # Extract values from config
    try:
        health_check_url = config['dev']['url']
        sns_topic_arn = config['dev']['sns_topic_arn']
        region = config['dev']['region']
    except KeyError as e:
        logging.error(f"Missing key in config.yaml: {e}")
        return

    # Perform health check
    if not check_health(health_check_url):
        # Send SNS alert if check fails
        try:
            client = boto3.client('sns', region_name=region)
            message = f"Health check failed for {health_check_url} at {datetime.utcnow().isoformat()} UTC"
            client.publish(
                TopicArn=sns_topic_arn,
                Message=message,
                Subject='Health Check Alert'
            )
            logging.info(f"Sent alert to SNS: {message}")
        except Exception as e:
            logging.error(f"Failed to publish to SNS: {e}")
    else:
        logging.info(f"Health check passed for {health_check_url}")

if __name__ == "__main__":
    main()

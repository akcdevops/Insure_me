#!/bin/bash

# 1. Gather necessary information
# Replace with your AWS credentials and server details
# aws_access_key_id=${AWS_ACCESS_KEY_ID}
# aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
region="ap-south-1"
username="ubuntu"  # Adjust based on your server user
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/dwithitechnologies/jenkins/Ns4hYfQDpS0BuFhIbfPVKFmO"


# 2. Fetch a list of running EC2 instance IDs
instances_ids=$(aws ec2 describe-instances \
    --region $region \
    --output text \
    --query 'Reservations[*].Instances[?State.Name == `running`].InstanceId' \
    --profile default)
echo $instances_ids
# 3. Iterate through each instance ID and copy SSH key
for instance_id in $instances_ids; do
    public_ip=$(aws ec2 describe-instances --region $region --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text --profile default)
    MESSAGE="Dev-Insureme accessable link: http://${INSTANCE_IP}:8080"
    curl -X POST -H 'Content-Type: application/json' --data "{\"text\": \"${MESSAGE}\"}" "${SLACK_WEBHOOK_URL}"

done
#--query 'Reservations[*].Instances[*].PublicIpAddress' \

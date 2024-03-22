import boto3

def get_ec2_instances():
    ec2_client = boto3.client('ec2',
                              aws_access_key_id= '${AWS_ACCESS_KEY_ID}',
                              aws_secret_access_key='${AWS_SECRET_ACCESS_KEY}')
    reservations = ec2_client.describe_instances().get('Reservations', [])
    instances = []
    for reservation in reservations:
        for instance in reservation['Instances']:
            instances.append(instance)
    return instances

def generate_inventory(instances):
    inventory = {'all': {'hosts': []}}
    for instance in instances:
        inventory['all']['hosts'].append({
            'public_ip': instance['PublicIpAddress'],
            'private_ip': instance['PrivateIpAddress'],
            # Add other relevant instance information as needed
        })
    return inventory

if __name__ == '__main__':
    instances = get_ec2_instances()
    inventory = generate_inventory(instances)
    print(json.dumps(inventory))

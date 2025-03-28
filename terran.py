#!/usr/bin/env python3
import boto3
import paramiko
import json
import time
import os
import tempfile

# --- Configuration ---
SECRET_NAME = "appserver-secret2"
REGION = "us-east-1"
INSPECTOR_INSTALL_CMD = "curl -s https://inspector-agent.amazonaws.com/install.sh | sudo bash"
SSH_TIMEOUT = 10
DELAY_BETWEEN_INSTANCES = 2
MAX_RETRIES = 3

# --- Initialize AWS Clients ---
ec2 = boto3.client('ec2', region_name=REGION)
secrets = boto3.client('secretsmanager', region_name=REGION)

def get_ssh_credentials():
    secret = secrets.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(secret['SecretString'])

def list_instances():
    instances = []
    response = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            public_ip = instance.get('PublicIpAddress', None)
            name = next((tag['Value'] for tag in instance.get('Tags', []) if tag['Key'] == 'Name'), None)
            if public_ip and name:
                instances.append({'public_ip': public_ip, 'name': name})
    return instances

def install_agent(ip, username, private_key):
    temp_dir = tempfile.gettempdir()
    key_path = os.path.join(temp_dir, f"{ip.replace('.', '_')}.pem")
    os.makedirs(temp_dir, exist_ok=True)
    
    with open(key_path, "w") as f:
        f.write(private_key)
    os.chmod(key_path, 0o600)
    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        print(f"Connecting to {ip} as {username}...")
        ssh.connect(ip, username=username, key_filename=key_path, timeout=SSH_TIMEOUT)
        stdin, stdout, stderr = ssh.exec_command(INSPECTOR_INSTALL_CMD)
        exit_code = stdout.channel.recv_exit_status()
        if exit_code == 0:
            print(f"SUCCESS: Inspector installed on {ip}")
        else:
            error_msg = stderr.read().decode()
            print(f"ERROR: Failed on {ip}: {error_msg}")
    except Exception as e:
        print(f"WARNING: Failed to connect to {ip}: {str(e)}")
    finally:
        ssh.close()
        os.remove(key_path)

def main():
    credentials = get_ssh_credentials()
    instances = list_instances()
    print(f"Found {len(instances)} instances.")
    
    for instance in instances:
        name = instance['name']
        ip = instance['public_ip']
        if name in credentials:
            print(f"Processing {name} ({ip})...")
            creds = credentials[name]
            install_agent(ip, creds['username'], creds['private_key'])
            time.sleep(DELAY_BETWEEN_INSTANCES)
        else:
            print(f"Skipping {name}: No credentials found.")

if __name__ == "__main__":
    main()
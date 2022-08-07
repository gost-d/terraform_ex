#!/bin/bash 
        add-apt-repository universe 
        apt update
        apt install -y python3-pip
        python3 -m pip install boto3
        add-apt-repository -y -u ppa:ansible/ansible    
        apt install -y ansible
        python3 -m pip install awscli
        aws s3 cp s3://ec2bucket123456789 /home/ubuntu/ansible --recursive
        ansible-galaxy install geerlingguy.mysql
        export ANSIBLE_HOST_KEY_CHECKING=False
        chmod 0600 /home/ubuntu/ansible/mysql_key.pem
        ansible-playbook /home/ubuntu/ansible/playbook_ec2_mysql.yml -u ubuntu --private-key=/home/ubuntu/ansible/mysql_key.pem

#!/bin/bash
set -e
exec > >(tee /var/log/controller-setup.log) 2>&1

# Wait for apt/dpkg locks 
while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/lib/dpkg/lock >/dev/null 2>&1; do
  sleep 5
done

export DEBIAN_FRONTEND=noninteractive
# install ansible
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# install geerlingguy.docker & it waits until ansible-galaxy install properly
until ansible-galaxy role install geerlingguy.docker; do
  echo "ansible-galaxy install failed, retrying in 10 seconds"
  sleep 10
done

# checking for existing ssm user & add sudo privelege for apt only
id ssm-user &>/dev/null || useradd -m -s /bin/bash ssm-user
cat > /etc/sudoers.d/ssm-user <<'EOF'
ssm-user ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt
EOF
chmod 440 /etc/sudoers.d/ssm-user

# create folder for ssh 
mkdir -p /home/ssm-user/.ssh
chmod 700 /home/ssm-user/.ssh

# add ssh key to the directory
cat > /home/ssm-user/.ssh/id_ed25519 <<'EOF'
${ssh_private_key}
EOF
chmod 600 /home/ssm-user/.ssh/id_ed25519

# add github ssh key to the directory
cat > /home/ssm-user/.ssh/id_github <<'EOF'
${github_deploy_key}
EOF
chmod 600 /home/ssm-user/.ssh/id_github

# use deploy key for clone github
cat > /home/ssm-user/.ssh/config <<'EOF'
Host github.com
  IdentityFile /home/ssm-user/.ssh/id_github
  StrictHostKeyChecking accept-new
EOF
chmod 600 /home/ssm-user/.ssh/config
chown -R ssm-user:ssm-user /home/ssm-user

# Looping to clone the repo devops-bootcamp-project
REPO_DIR=/home/ssm-user/devops-bootcamp-project
MAX_RETRIES=5
RETRY_DELAY=10
attempt=1
until sudo -u ssm-user git clone git@github.com:Arifbhrn/devops-bootcamp-project.git "$REPO_DIR"; do
  if [ $attempt -ge $MAX_RETRIES ]; then
    echo "FATAL: git clone failed after $MAX_RETRIES attempts" >&2
    exit 1
  fi
  echo "git clone failed (attempt $attempt/$MAX_RETRIES), retrying in $${RETRY_DELAY}s..."
  attempt=$((attempt + 1))
  sleep $RETRY_DELAY
done

# Generate inventory.ini file for ansible to find the right ec2 to connect
cat > $REPO_DIR/inventory.ini <<EOF
[web]
${web_server_ip}

[monitor]
${monitoring_ip}

[nodes:children]
web
monitor

[nodes:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ssm-user/.ssh/id_ed25519
EOF
chown ssm-user:ssm-user $REPO_DIR/inventory.ini
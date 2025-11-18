# Ansible Multi-Environment Web Server Configuration

This Ansible project automates the setup of nginx web servers across multiple environments (local, development, production) using a role-based architecture.

## 🚀 Features

- Multi-environment support (local, development, production)
- Role-based architecture with nginx and webapp roles
- Cross-platform support (Ubuntu/Debian and CentOS/RHEL)
- Simple deployment commands

## 📁 Project Structure

```
.
├── inventories/          # Environment configurations
│   ├── local/           # Local environment
│   ├── dev/             # Development environment  
│   └── prod/            # Production environment
├── roles/               # Ansible roles
│   ├── nginx/           # Web server setup
│   └── webapp/          # Application deployment
├── playbooks/           # Deployment playbooks
├── ansible.cfg          # Ansible configuration
└── README.md           # This file
```

## 🏗️ Environment Overview

### Local Environment
- **Purpose**: Local development and testing
- **Port**: 8080
- **Access**: http://localhost:8080

### Development Environment
- **Purpose**: Team development and integration testing
- **Port**: 8080
- **Hosts**: Configurable development servers

### Production Environment
- **Purpose**: Live production deployment
- **Port**: 80 (HTTP) / 443 (HTTPS)
- **Hosts**: Production server cluster

## 🚀 Quick Start

### 1. Prerequisites

#### Install Ansible

```bash
# Install Ansible
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# CentOS/RHEL
sudo yum install epel-release && sudo yum install ansible

# macOS
brew install ansible
```

#### Create Vault Password File

This project uses Ansible Vault to encrypt sensitive variables. You need to create a vault password file:

```bash
# Create the vault password file in the project root
echo "your_vault_password_here" > .vault_pass

# Secure the file permissions (important for security)
chmod 600 .vault_pass

# Add to .gitignore to prevent committing the password
echo ".vault_pass" >> .gitignore
```

**Important Security Notes:**
- Replace `your_vault_password_here` with a strong, unique password
- Never commit `.vault_pass` to version control
- Use the same password that was used to encrypt the variables in host_vars files
- Store the password securely (password manager, secure notes, etc.)

### 2. Configure Your Environments

Update the inventory files with your actual server details:

```bash
# Edit local environment (optional - uses localhost)
vim inventories/local/hosts.yml

# Edit development environment
vim inventories/dev/hosts.yml

# Edit production environment
vim inventories/prod/hosts.yml
```

### 3. SSH Authentication Setup

The project is configured to use SSH key authentication for dev and prod environments:

- **Development**: Uses `~/.ssh/dev_key` 
- **Production**: Uses `~/.ssh/prod_key`
- **Local**: Uses local connection (no SSH needed)

**If you have SSH keys configured** (recommended):
- No additional SSH options needed
- Commands work as shown in examples

**If you want to use SSH password authentication instead**:
- Add `--ask-pass` to all ansible-playbook commands for dev/prod
- Remove or comment out `ansible_ssh_private_key_file` from host_vars files

### 4. Deploy to Your Environment

Since this project uses encrypted variables and requires sudo privileges, you'll need to provide both the vault password and sudo password when running playbooks:

```bash
# Deploy to local environment
ansible-playbook -i inventories/local/hosts.yml playbooks/webapp.yml --vault-id default@.vault_pass --ask-become-pass

# Deploy to development (with dry run first)
ansible-playbook -i inventories/dev/hosts.yml playbooks/webapp.yml --check --vault-id default@.vault_pass --ask-become-pass
ansible-playbook -i inventories/dev/hosts.yml playbooks/webapp.yml --vault-id default@.vault_pass --ask-become-pass

# Deploy to production
ansible-playbook -i inventories/prod/hosts.yml playbooks/webapp.yml --vault-id default@.vault_pass --ask-become-pass
```

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

# Install ansible-lint for code quality checking (optional but recommended)
pip install ansible-lint
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

## 🔍 Code Quality and Linting

This project includes both ansible-lint and yamllint configurations for maintaining code quality and best practices.

### Running ansible-lint

```bash
# Lint all playbooks and roles
ansible-lint

# Lint specific files
ansible-lint playbooks/webapp.yml
ansible-lint roles/nginx/tasks/main.yml

# Lint with specific rules only
ansible-lint --tags yaml,syntax

# Show all available rules
ansible-lint --list-rules

# Generate a report
ansible-lint --format json > lint-report.json
```

### Running yamllint

yamllint validates YAML syntax and formatting across all project files:

```bash
# Install yamllint
pip install yamllint

# Lint all YAML files in the project
yamllint .

# Lint specific files
yamllint playbooks/webapp.yml
yamllint inventories/dev/hosts.yml

# Lint with specific format
yamllint -f parsable .

# Show configuration being used
yamllint --print-config

# Lint and show only errors (ignore warnings)
yamllint -d relaxed .
```

### Running Both Linters with lint.sh

The project includes a convenient script that runs both ansible-lint and yamllint together:

```bash
# Make the script executable (first time only)
chmod +x lint.sh

# Run both linters
./lint.sh
```

The `lint.sh` script provides:

- **Colored output** for easy reading (green for success, red for errors, yellow for info)
- **Summary report** showing which linters passed or failed
- **Error counting** to track the number of issues found
- **Helpful suggestions** on how to run individual linters for detailed output
- **Exit codes** for CI/CD integration (0 = success, 1 = issues found)

#### Script Output Example

When all checks pass:
```
🔍 Running Ansible and YAML linting...
========================================

📋 Running ansible-lint...
----------------------------------------
✅ ansible-lint: No issues found

📝 Running yamllint...
----------------------------------------
✅ yamllint: No issues found

📊 Summary
========================================
🎉 All linting checks passed!
```

When issues are found:
```
🔍 Running Ansible and YAML linting...
========================================

📋 Running ansible-lint...
----------------------------------------
❌ ansible-lint: Issues found

📝 Running yamllint...
----------------------------------------
✅ yamllint: No issues found

📊 Summary
========================================
⚠️  Some linting issues found:
  - ansible-lint: Failed

Run the individual commands to see detailed output:
  ansible-lint playbooks/ roles/
```

#### Integration with CI/CD

The script is designed to work well in automated environments:

```bash
# In your CI/CD pipeline
./lint.sh
if [ $? -eq 0 ]; then
    echo "Linting passed, proceeding with deployment"
else
    echo "Linting failed, stopping pipeline"
    exit 1
fi
```

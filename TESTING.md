# Molecule Testing Guide

This project uses Molecule for automated testing of Ansible roles and playbooks using Docker containers.

## Test Structure

```
.
├── molecule/default/              # Full integration tests (nginx + webapp)
│   ├── molecule.yml              # Test configuration
│   ├── converge.yml              # Playbook to test
│   └── verify.yml                # Verification tests
├── roles/nginx/molecule/default/ # Nginx role tests
│   ├── molecule.yml
│   ├── converge.yml
│   └── verify.yml
└── roles/webapp/molecule/default/ # Webapp role tests
    ├── molecule.yml
    ├── converge.yml
    └── verify.yml
```

## Prerequisites

### 1. Install Docker

Molecule uses Docker to create test containers:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER  # Log out and back in after this

# macOS
brew install docker
# Or install Docker Desktop from https://www.docker.com/products/docker-desktop

# Verify installation
docker --version
```

### 2. Install Molecule and Dependencies

```bash
# Navigate to project root
cd ~/workspace/ansible_configure_web_server

# Create a virtual environment (required on Ubuntu 23.04+)
python3 -m venv molecule-venv

# Activate the virtual environment
source molecule-venv/bin/activate

# Install from requirements file
pip install -r requirements-test.txt

# Or install manually
pip install molecule molecule-docker ansible ansible-lint docker
```

**Important:** Always activate the virtual environment before running tests:
```bash
source molecule-venv/bin/activate
```

## Running Tests

### Test Individual Roles

```bash
# Test nginx role only
cd roles/nginx
molecule test

# Test webapp role only
cd roles/webapp
molecule test
```

### Test Full Integration

```bash
# Test complete deployment (nginx + webapp)
molecule test
```

### Molecule Commands

```bash
# Create test environment
molecule create

# Run the playbook
molecule converge

# Run verification tests
molecule verify

# Login to test container for debugging
molecule login

# Destroy test environment
molecule destroy

# Full test cycle (create, converge, verify, destroy)
molecule test

# Test on specific platform
molecule test --platform-name nginx-ubuntu
molecule test --platform-name nginx-centos
```

## What Gets Tested

### Nginx Role Tests
- ✅ Nginx package is installed
- ✅ Nginx service is running and enabled
- ✅ Configuration files are created correctly
- ✅ Nginx responds on port 80
- ✅ Works on both Ubuntu and CentOS

### Webapp Role Tests
- ✅ Web directory is created with correct permissions
- ✅ index.html file exists and has correct permissions
- ✅ HTML content is valid

### Full Integration Tests
- ✅ Complete deployment works end-to-end
- ✅ Nginx serves the webapp content
- ✅ Web content is accessible via HTTP
- ✅ All services are running correctly

## Test Platforms

Tests run on multiple platforms to ensure compatibility:
- **Ubuntu 22.04** (Debian-based)
- **Rocky Linux 9** (RedHat-based)

## Troubleshooting

### Docker Permission Denied

```bash
# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Container Won't Start

```bash
# Check Docker is running
sudo systemctl status docker

# Pull images manually
docker pull geerlingguy/docker-ubuntu2204-ansible:latest
docker pull geerlingguy/docker-rockylinux9-ansible:latest
```

### Tests Fail on Systemd

The test containers use systemd-enabled images. If you see systemd errors:

```bash
# Ensure privileged mode is enabled in molecule.yml
privileged: true
```

### Clean Up Old Containers

```bash
# Remove all molecule containers
docker ps -a | grep molecule | awk '{print $1}' | xargs docker rm -f

# Remove all molecule networks
docker network ls | grep molecule | awk '{print $1}' | xargs docker network rm
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Molecule Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Install dependencies
        run: pip install -r requirements-test.txt
      - name: Run molecule tests
        run: molecule test
```

### GitLab CI Example

```yaml
molecule:
  image: python:3.10
  services:
    - docker:dind
  before_script:
    - pip install -r requirements-test.txt
  script:
    - molecule test
```

## Quick Reference

```bash
# Setup (first time only)
cd ~/workspace/ansible_configure_web_server
python3 -m venv molecule-venv
source molecule-venv/bin/activate
pip install -r requirements-test.txt

# Activate virtual environment (every time)
source molecule-venv/bin/activate

# Run all tests
molecule test                    # Full integration
cd roles/nginx && molecule test  # Nginx only
cd roles/webapp && molecule test # Webapp only

# Debug
molecule create                  # Create containers
molecule converge                # Run playbook
molecule login                   # SSH into container
molecule verify                  # Run tests
molecule destroy                 # Clean up

# Deactivate when done
deactivate
```

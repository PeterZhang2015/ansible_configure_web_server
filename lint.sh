#!/bin/bash

# Ansible and YAML Linting Script
# This script runs both ansible-lint and yamllint to ensure code quality

echo "🔍 Running Ansible and YAML linting..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize counters
ansible_lint_errors=0
yamllint_errors=0

echo -e "\n${YELLOW}📋 Running ansible-lint...${NC}"
echo "----------------------------------------"

# Run ansible-lint on playbooks and roles
if ansible-lint playbooks/ roles/ 2>/dev/null; then
    echo -e "${GREEN}✅ ansible-lint: No issues found${NC}"
else
    ansible_lint_errors=$?
    echo -e "${RED}❌ ansible-lint: Issues found${NC}"
fi

echo -e "\n${YELLOW}📝 Running yamllint...${NC}"
echo "----------------------------------------"

# Run yamllint on all YAML files
if yamllint -d relaxed . 2>/dev/null; then
    echo -e "${GREEN}✅ yamllint: No issues found${NC}"
else
    yamllint_errors=$?
    echo -e "${RED}❌ yamllint: Issues found${NC}"
fi

echo -e "\n${YELLOW}📊 Summary${NC}"
echo "========================================"

if [ $ansible_lint_errors -eq 0 ] && [ $yamllint_errors -eq 0 ]; then
    echo -e "${GREEN}🎉 All linting checks passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some linting issues found:${NC}"
    [ $ansible_lint_errors -ne 0 ] && echo -e "  - ansible-lint: ${RED}Failed${NC}"
    [ $yamllint_errors -ne 0 ] && echo -e "  - yamllint: ${RED}Failed${NC}"
    echo ""
    echo "Run the individual commands to see detailed output:"
    [ $ansible_lint_errors -ne 0 ] && echo "  ansible-lint playbooks/ roles/"
    [ $yamllint_errors -ne 0 ] && echo "  yamllint -d relaxed ."
    exit 1
fi
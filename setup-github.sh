#!/bin/bash

# Wedding Invitation - GitHub Setup Script
# This script helps you push the project to your own GitHub repository

echo "========================================="
echo "Wedding Invitation - GitHub Setup"
echo "========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Get user's GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

# Get repository name
read -p "Enter your repository name (e.g., my-wedding-invitation): " REPO_NAME

# Confirm
echo ""
echo "You are about to push to: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "Setting up Git repository..."

# Remove original remote
git remote remove origin 2>/dev/null || true

# Add new remote
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Ensure we're on main branch
git branch -M main

echo ""
echo "Git remote configured successfully!"
echo ""
echo "Next steps:"
echo "1. Create a new repository on GitHub: https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - Make it private or public (your choice)"
echo "   - DO NOT initialize with README"
echo ""
echo "2. After creating the repository, run:"
echo "   git push -u origin main"
echo ""
echo "3. Follow the DEPLOYMENT.md guide to set up GitHub Actions"
echo ""
echo "========================================="

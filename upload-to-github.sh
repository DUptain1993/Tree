#!/bin/bash

# Upload TWRP Device Tree to GitHub
# This script helps you upload the device tree to your GitHub repository

set -e

echo "=========================================="
echo "TWRP Device Tree GitHub Upload Script"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed"
    echo "Install with: pkg install git"
    exit 1
fi

# Get GitHub username
echo "Enter your GitHub username:"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GitHub username cannot be empty"
    exit 1
fi

# Get repository name
echo ""
echo "Enter repository name (press Enter for default: android_device_motorola_kansas):"
read -r REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="android_device_motorola_kansas"
fi

# Confirm details
echo ""
echo "Repository will be created at:"
echo "https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "Is this correct? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted by user"
    exit 0
fi

# Initialize git if not already initialized
if [ ! -d .git ]; then
    echo ""
    echo "Initializing git repository..."
    git init
    git branch -M main
else
    echo ""
    echo "Git repository already initialized"
fi

# Configure git user if not configured
if [ -z "$(git config user.name)" ]; then
    echo ""
    echo "Enter your name for git commits:"
    read -r GIT_NAME
    git config user.name "$GIT_NAME"
fi

if [ -z "$(git config user.email)" ]; then
    echo ""
    echo "Enter your email for git commits:"
    read -r GIT_EMAIL
    git config user.email "$GIT_EMAIL"
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo ""
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Build outputs
*.o
*.ko
*.so
*.a
out/
.repo/

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.log
*.tmp
EOF
fi

# Add all files
echo ""
echo "Adding files to git..."
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    # Create commit
    echo ""
    echo "Creating commit..."
    git commit -m "Add TWRP device tree for Motorola Moto G - 2025 (kansas)

Device: Motorola Moto G - 2025
Codename: kansas
Platform: MediaTek MT6835
Android: 15 (API 35)

Features:
- A/B Seamless Updates
- Dynamic Partitions
- File-Based Encryption
- AVB 2.0 Verified Boot
- Trustonic TEE
- TWRP Recovery Support"
fi

# Add remote if not exists
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
if git remote | grep -q '^origin$'; then
    echo ""
    echo "Updating remote URL..."
    git remote set-url origin "$REMOTE_URL"
else
    echo ""
    echo "Adding remote..."
    git remote add origin "$REMOTE_URL"
fi

# Show instructions
echo ""
echo "=========================================="
echo "NEXT STEPS:"
echo "=========================================="
echo ""
echo "1. Create the repository on GitHub:"
echo "   Go to: https://github.com/new"
echo "   Repository name: $REPO_NAME"
echo "   Make it PUBLIC (required for free GitHub Actions)"
echo "   DO NOT initialize with README"
echo ""
echo "2. Get a Personal Access Token:"
echo "   Go to: https://github.com/settings/tokens"
echo "   Click 'Generate new token (classic)'"
echo "   Select scopes: repo, workflow"
echo "   Copy the token"
echo ""
echo "3. Push to GitHub:"
echo "   Run: git push -u origin main"
echo "   Username: $GITHUB_USERNAME"
echo "   Password: [paste your token]"
echo ""
echo "4. Enable GitHub Actions:"
echo "   Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/actions"
echo "   Click 'I understand my workflows, go ahead and enable them'"
echo ""
echo "5. Start the build:"
echo "   Click 'Actions' tab"
echo "   Select 'Build TWRP Recovery'"
echo "   Click 'Run workflow'"
echo "   Select: android-14.0 branch"
echo "   Click 'Run workflow'"
echo ""
echo "=========================================="
echo ""
echo "Ready to push? (y/n)"
read -r PUSH_NOW

if [ "$PUSH_NOW" = "y" ] || [ "$PUSH_NOW" = "Y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    echo "Enter your Personal Access Token when prompted for password"
    git push -u origin main

    if [ $? -eq 0 ]; then
        echo ""
        echo "Success! Your device tree has been uploaded to:"
        echo "https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        echo ""
        echo "Now go enable GitHub Actions and start your build!"
    else
        echo ""
        echo "Push failed. Please check your credentials and try again with:"
        echo "git push -u origin main"
    fi
else
    echo ""
    echo "You can push later with:"
    echo "git push -u origin main"
fi

echo ""
echo "For detailed build instructions, see GITHUB_BUILD_INSTRUCTIONS.md"

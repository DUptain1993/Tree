#!/bin/bash
#
# Copyright (C) 2025 The TWRP Open Source Project
# Copyright (C) 2025 DUptain
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Simple script to trigger a GitHub Actions workflow

# --- Configuration ---
# Your GitHub Username
GITHUB_USER="DUptain1993"
# The name of this repository
GITHUB_REPO="Tree"
# The workflow file to trigger
WORKFLOW_FILE="build-twrp.yml"
# The branch of the TWRP manifest to use for building
# Recommended: "android-14.0" (stable) or "android-15.0" (if available)
MANIFEST_BRANCH="android-14.0"

# --- Script Logic ---

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# 1. Check if gh is installed
if ! command -v gh &> /dev/null; then
    print_message "ERROR: 'gh' command not found."
    echo "Please install the GitHub CLI to use this script."
    echo "Installation instructions: https://cli.github.com/"
    exit 1
fi

# 2. Authenticate with GitHub
print_message "Authenticating with GitHub"
if ! gh auth status &> /dev/null; then
    echo "You are not logged into GitHub."
    echo "Please run 'gh auth login' to authenticate."
    exit 1
fi
echo "Successfully authenticated as '$(gh auth status -h github.com | awk '/Logged in to github.com as/ {print $6}')'."

# 3. Trigger the workflow
print_message "Triggering the build workflow"
echo "Repository: $GITHUB_USER/$GITHUB_REPO"
echo "Workflow: $WORKFLOW_FILE"
echo "Branch: $MANIFEST_BRANCH"
echo

if gh workflow run "$WORKFLOW_FILE" -R "$GITHUB_USER/$GITHUB_REPO" -f manifest_branch="$MANIFEST_BRANCH"; then
    echo
    print_message "SUCCESS: Workflow triggered!"
    echo "Go to your Actions tab to see the progress:"
    echo "https://github.com/$GITHUB_USER/$GITHUB_REPO/actions"
else
    print_message "ERROR: Failed to trigger workflow."
    echo "Please check the repository and workflow name."
fi

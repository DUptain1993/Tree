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
# This script intelligently initializes and syncs the TWRP manifest repository.

set -e

# --- Configuration & Arguments ---
MANIFEST_URL="$1"
DESIRED_BRANCH="$2"
WORKDIR="${3:-$HOME/twrp}"
JOBS="${4:-4}"
REPO_BIN="$HOME/bin/repo"

echo "ci/init_repo.sh: starting in $WORKDIR"
echo "Manifest: $MANIFEST_URL"
echo "Desired branch: $DESIRED_BRANCH"
echo "Workdir: $WORKDIR"
echo "Jobs: $JOBS"

# --- Install repo tool if needed ---
if [ ! -f "$REPO_BIN" ]; then
    echo "repo tool not found; installing to $REPO_BIN"
    mkdir -p "$(dirname "$REPO_BIN")"
    curl -o "$REPO_BIN" https://storage.googleapis.com/git-repo-downloads/repo
    chmod a+x "$REPO_BIN"
fi
echo "Using repo command at: $REPO_BIN"

# --- Branch Selection Logic ---
echo "Querying available branches from manifest repo: $MANIFEST_URL"
AVAILABLE_BRANCHES=$(git ls-remote --heads "$MANIFEST_URL" | cut -f2 | sed 's#refs/heads/##')
echo "Available branches from manifest:"
echo "$AVAILABLE_BRANCHES"

FINAL_BRANCH=""

# 1. Check if the exact desired branch exists
if echo "$AVAILABLE_BRANCHES" | grep -q "^${DESIRED_BRANCH}$"; then
    FINAL_BRANCH="$DESIRED_BRANCH"
    echo "Desired branch '${DESIRED_BRANCH}' found."
# 2. If not, find the highest available twrp-* branch
else
    echo "Desired branch '${DESIRED_BRANCH}' not found. Searching for the best fallback."
    # Filter for twrp- branches, sort them by version, and get the latest one
    BEST_FALLBACK=$(echo "$AVAILABLE_BRANCHES" | grep '^twrp-' | sort -V | tail -n 1)
    if [ -n "$BEST_FALLBACK" ]; then
        FINAL_BRANCH="$BEST_FALLBACK"
        echo "Using best fallback branch: ${FINAL_BRANCH}"
    else
        # 3. As a last resort, try 'main' or 'master'
        if echo "$AVAILABLE_BRANCHES" | grep -q "^main$"; then
            FINAL_BRANCH="main"
        elif echo "$AVAILABLE_BRANCHES" | grep -q "^master$"; then
            FINAL_BRANCH="master"
        else
            echo "ERROR: No suitable branch found in the manifest repository." >&2
            exit 1
        fi
        echo "Warning: No twrp-* branch found. Using last resort: ${FINAL_BRANCH}"
    fi
fi

echo "Using manifest branch: ${FINAL_BRANCH}"

# --- Initialize and Sync Repo ---
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "Running repo init -u ${MANIFEST_URL} -b ${FINAL_BRANCH}"
"$REPO_BIN" init -u "${MANIFEST_URL}" -b "${FINAL_BRANCH}" --depth=1 --no-repo-verify

for i in {1..5}; do
    echo "repo sync attempt $i/5"
    if "$REPO_BIN" sync -c -j"${JOBS}" --no-clone-bundle --no-tags --optimized-fetch --prune; then
        echo "Repo sync successful."
        exit 0
    fi
    if [ $i -lt 5 ]; then
        echo "Repo sync failed. Retrying in $((15 * i)) seconds..."
        sleep $((15 * i))
    fi
done

echo "ERROR: Repo sync failed after 5 attempts." >&2
exit 1

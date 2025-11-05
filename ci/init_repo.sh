#!/usr/bin/env bash
# Usage: ci/init_repo.sh <manifest_url> [desired_branch] [workdir] [jobs]
# Example: ci/init_repo.sh https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git android-15.0 ~/twrp 8

set -euo pipefail
MANIFEST_URL="${1:-}"
DESIRED="${2:-}"
WORKDIR="${3:-$HOME/twrp}"
JOBS="${4:-8}"
REPO_BIN="${REPO_BIN:-$HOME/bin/repo}"

if [[ -z "$MANIFEST_URL" ]]; then
  echo "Usage: $0 <manifest_url> [desired_branch] [workdir] [jobs]"
  exit 2
fi

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Ensure repo tool present
if ! command -v "$REPO_BIN" >/dev/null 2>&1; then
  echo "repo tool not found at $REPO_BIN — installing to $HOME/bin/repo"
  mkdir -p "$(dirname "$REPO_BIN")"
  curl -fsSL "https://storage.googleapis.com/git-repo-downloads/repo" -o "$REPO_BIN"
  chmod +x "$REPO_BIN"
fi

# Make sure git can reach the manifest
echo "Querying available branches from manifest repo: $MANIFEST_URL"
mapfile -t branches < <(git ls-remote --heads --refs "$MANIFEST_URL" 2>/dev/null | awk '{print $2}' | sed 's#refs/heads/##' || true)

if [[ ${#branches[@]} -eq 0 ]]; then
  echo "ERROR: Could not list branches from $MANIFEST_URL"
  echo "Check network access, repo URL and that the repository exists. Aborting."
  exit 3
fi

echo "Available branches:"
for b in "${branches[@]}"; do echo "  $b"; done

pick_branch() {
  requested="$1"
  # If requested branch exists, use it
  if [[ -n "$requested" ]]; then
    for b in "${branches[@]}"; do
      if [[ "$b" == "$requested" ]]; then
        echo "$b"
        return
      fi
    done
  fi

  # Prefer exact android-* branches and choose the highest numeric version
  android_branches=()
  for b in "${branches[@]}"; do
    if [[ "$b" =~ ^android-([0-9]+) ]]; then
      android_branches+=("$b")
    fi
  done

  if [[ ${#android_branches[@]} -gt 0 ]]; then
    # sort by numeric portion descending and pick first
    printf "%s\n" "${android_branches[@]}" | sort -Vr | head -n1
    return
  fi

  # Fallback to main, then master, then first available
  for candidate in main master; do
    for b in "${branches[@]}"; do
      if [[ "$b" == "$candidate" ]]; then
        echo "$b"
        return
      fi
    done
  done

  # Last resort: return the first available branch
  echo "${branches[0]}"
}

BRANCH="$(pick_branch "$DESIRED")"
echo "Using manifest branch: $BRANCH"

# Some environments reuse an existing .repo; remove or re-init depending on desired behavior
if [[ -d .repo ]]; then
  echo "Removing existing .repo to avoid partial state"
  rm -rf .repo
fi

# Repo init + sync with retry for transient network errors
echo "Running repo init -u $MANIFEST_URL -b $BRANCH"
"$REPO_BIN" init --depth=1 -u "$MANIFEST_URL" -b "$BRANCH" || { echo "repo init failed"; exit 4; }

MAX_ATTEMPTS=5
for attempt in $(seq 1 $MAX_ATTEMPTS); do
  echo "repo sync attempt $attempt/$MAX_ATTEMPTS"
  if "$REPO_BIN" sync -c -j"$JOBS" --force-sync --no-clone-bundle --no-tags --fail-fast; then
    echo "repo sync succeeded"
    exit 0
  fi
  echo "repo sync failed; sleeping $((5 * attempt)) seconds and retrying..."
  sleep $((5 * attempt))
done

echo "repo sync failed after $MAX_ATTEMPTS attempts"
exit 5

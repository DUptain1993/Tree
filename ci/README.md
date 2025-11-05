# CI Scripts

## init_repo.sh

This script intelligently initializes and syncs the TWRP manifest repository with automatic branch detection.

### Problem it solves

The `repo init` command fails when trying to fetch a branch that doesn't exist in the manifest repository (e.g., `android-15.0` when only `android-14.0` exists). This script:

1. Queries the manifest repository to discover available branches
2. Uses the requested branch if it exists
3. Falls back to the highest available `android-*` branch
4. Further falls back to `main`/`master` if needed
5. Includes retry logic for network failures

### Usage

```bash
./ci/init_repo.sh <manifest_url> [desired_branch] [workdir] [jobs]
```

### Example

```bash
./ci/init_repo.sh \
  https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  android-15.0 \
  ~/twrp \
  8
```

### Behavior

- If `android-15.0` exists: uses `android-15.0`
- If `android-15.0` doesn't exist: uses highest `android-*` branch (e.g., `android-14.0`)
- If no `android-*` branches exist: uses `main` or `master`
- Retries `repo sync` up to 5 times with exponential backoff

### Manual troubleshooting

List available branches:
```bash
git ls-remote --heads https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git
```

Test the script locally:
```bash
./ci/init_repo.sh https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git android-14.0 ~/twrp-test 4
```

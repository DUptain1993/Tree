# Building TWRP Recovery Using GitHub Actions

This guide will walk you through building TWRP recovery for your Motorola Moto G - 2025 (kansas) using GitHub's free cloud build service.

## Prerequisites

- GitHub account (free)
- Git installed on Termux (already available)
- Internet connection

## Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `android_device_motorola_kansas` (or any name you prefer)
3. Description: `TWRP device tree for Motorola Moto G - 2025 (kansas)`
4. Choose **Public** (required for free GitHub Actions)
5. Do NOT initialize with README (we already have files)
6. Click "Create repository"

### Option B: Using GitHub CLI (if installed)

```bash
gh repo create android_device_motorola_kansas --public --description "TWRP device tree for Motorola Moto G - 2025 (kansas)"
```

## Step 2: Push Device Tree to GitHub

After creating the repository, GitHub will show you commands. Use these commands from the TREE directory:

```bash
cd /data/data/com.termux/files/home/android16/TREE

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Add TWRP device tree for Motorola kansas"

# Add your GitHub repository as remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/android_device_motorola_kansas.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** You'll need to authenticate with GitHub. Use a Personal Access Token:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `workflow`
4. Generate and copy the token
5. Use the token as password when pushing

## Step 3: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. If prompted, click "I understand my workflows, go ahead and enable them"

## Step 4: Trigger the Build

### Method 1: Via GitHub Web Interface

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click "Build TWRP Recovery" workflow in the left sidebar
4. Click "Run workflow" button (top right)
5. Select options:
   - **TWRP Manifest Branch**: `android-14.0` (recommended for Android 15 devices)
   - **Device Tree Branch**: `main`
   - **Build Target**: `recoveryimage`

**Note:** For Android 15 devices, use `android-14.0` or `android-15.0` branch (if available). The android-14.0 branch has better compatibility with Android 15 features like dynamic partitions and FBE.
6. Click "Run workflow"

### Method 2: Via GitHub CLI

```bash
gh workflow run "Build TWRP Recovery" \
  -f MANIFEST_BRANCH=twrp-12.1 \
  -f DEVICE_TREE_BRANCH=main \
  -f BUILD_TARGET=recoveryimage
```

## Step 5: Monitor Build Progress

1. Go to "Actions" tab in your repository
2. Click on the running workflow
3. Click on "Build TWRP for Motorola Kansas" job
4. Watch the build logs in real-time

**Build Time:** Approximately 1-2 hours

**Build Steps:**
1. ✓ Checkout Device Tree (~5 seconds)
2. ✓ Cleanup Space (~30 seconds)
3. ✓ Install Dependencies (~2 minutes)
4. ✓ Setup Repo Tool (~10 seconds)
5. ✓ Initialize TWRP Repo (~30 seconds)
6. ✓ Sync TWRP Source (~20-40 minutes)
7. ✓ Clone Device Tree (~5 seconds)
8. ✓ Setup Build Environment (~10 seconds)
9. ✓ Build Recovery (~30-60 minutes)
10. ✓ Upload Artifacts (~30 seconds)

## Step 6: Download Recovery Image

Once the build completes successfully:

1. Go to the workflow run page
2. Scroll down to "Artifacts" section
3. Download:
   - `twrp-recovery-kansas-[build-number]` - Contains recovery.img
   - `build-info-[build-number]` - Contains build information

## Step 7: Extract and Verify

```bash
# Navigate to downloads
cd ~/storage/downloads

# Unzip the artifact (replace [build-number] with actual number)
unzip twrp-recovery-kansas-[build-number].zip

# Check recovery image
ls -lh recovery.img

# Verify MD5 (compare with build-info.txt)
md5sum recovery.img
```

## Step 8: Flash Recovery Image

### Prerequisites:
- Unlocked bootloader
- ADB and Fastboot installed
- USB debugging enabled

### Flashing Steps:

```bash
# Boot device to bootloader
adb reboot bootloader

# Flash recovery to both slots (A/B device)
fastboot flash recovery recovery.img
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img

# Reboot to recovery
fastboot reboot recovery
```

**Alternative:** Flash via existing recovery or custom ROM flasher.

## Troubleshooting

### Build Fails During Sync

**Problem:** Network timeout or repo sync failure

**Solution:**
- Re-run the workflow
- GitHub Actions has 6 hour timeout - plenty of time
- Network issues are temporary

### Build Fails During Compilation

**Problem:** Missing dependencies or kernel source

**Solution:**
- Check build logs for specific errors
- May need to add kernel source or prebuilt kernel
- You can modify `BoardConfig.mk` to use prebuilt kernel

### No Recovery Image in Artifacts

**Problem:** Build completed but no recovery.img

**Solution:**
- Check build logs for errors
- Ensure `recoveryimage` target is correct
- May need to try `bootimage` target instead

### Workflow Not Showing Up

**Problem:** GitHub Actions workflow not visible

**Solution:**
- Ensure repository is **public**
- Check that `.github/workflows/build-twrp.yml` exists
- GitHub Actions must be enabled in repository settings

## Advanced Configuration

### Using Different TWRP Version

Edit `.github/workflows/build-twrp.yml` and change the `MANIFEST_BRANCH` default:

```yaml
MANIFEST_BRANCH:
  default: 'twrp-11'  # or twrp-12.1, android-12.1
```

### Adding Kernel Source

If you want to build with kernel source instead of prebuilt:

1. Create kernel repository
2. Add kernel clone step to workflow
3. Update `BoardConfig.mk` with kernel path

### Scheduled Builds

Add to workflow file under `on:`:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly builds every Sunday
  workflow_dispatch:
    ...
```

## Resource Limits

GitHub Actions Free Tier:
- ✓ 2,000 minutes/month for private repos
- ✓ Unlimited for public repos
- ✓ 6 hour maximum per job
- ✓ 20 concurrent jobs

## Cost

**COMPLETELY FREE** if your repository is public!

## Next Steps

After successful build:

1. **Test Recovery:**
   - Boot to recovery mode
   - Test touch functionality
   - Test decryption (if applicable)
   - Test backup/restore

2. **Share Your Build:**
   - Create a release on GitHub
   - Share on XDA Developers
   - Help others with the same device

3. **Improve Device Tree:**
   - Add missing features
   - Fix bugs
   - Update for newer Android versions

## Getting Help

If you encounter issues:

1. Check build logs in GitHub Actions
2. Review error messages carefully
3. Search XDA Developers forums
4. Check TWRP device requirements
5. Ask in TWRP Telegram/Discord channels

## Alternative: Manual Build on PC

If GitHub Actions doesn't work, see `BUILD_INSTRUCTIONS_PC.txt` for building on a Linux PC.

---

**Generated:** 2025-11-04
**Device:** Motorola Moto G - 2025 (kansas)
**Platform:** MediaTek MT6835
**Android Version:** 15

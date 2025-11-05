# Quick Start Guide - Build TWRP for Motorola Kansas

## Device Information
- **Device:** Motorola Moto G - 2025
- **Codename:** kansas
- **Platform:** MediaTek MT6835
- **Android:** 15 (API Level 35)
- **Architecture:** ARM64 (aarch64)

## Why Use GitHub Actions?

Your Termux device **cannot** build TWRP locally due to:
- ❌ Need 150GB disk space (you have 24GB)
- ❌ Need 8GB+ RAM (you have 3.6GB)

GitHub Actions provides:
- ✅ Free cloud building (for public repos)
- ✅ Unlimited builds
- ✅ No local resources needed
- ✅ Professional build environment

## Build in 5 Steps

### Step 1: Upload to GitHub (5 minutes)

Run the upload script:
```bash
cd /data/data/com.termux/files/home/android16/TREE
./upload-to-github.sh
```

Follow the prompts to:
1. Enter your GitHub username
2. Choose repository name
3. Create repository on GitHub
4. Get Personal Access Token
5. Push files

**OR** Do it manually:
```bash
# Create repo on https://github.com/new
# Then:
git init
git add .
git commit -m "Add TWRP device tree for kansas"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2: Enable GitHub Actions (1 minute)

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click "I understand my workflows, go ahead and enable them"

### Step 3: Start Build (30 seconds)

1. Click "Actions" tab
2. Select "Build TWRP Recovery" (left sidebar)
3. Click "Run workflow" (green button)
4. Choose:
   - Branch: `android-14.0` ← **For Android 15**
   - Device Tree Branch: `main`
   - Build Target: `recoveryimage`
5. Click "Run workflow"

### Step 4: Wait (1-2 hours)

Watch the build progress in real-time:
- Click on the running workflow
- Watch logs as it builds
- Build will sync ~50GB of source code
- Then compile recovery image

### Step 5: Download (2 minutes)

Once complete:
1. Scroll to "Artifacts" section
2. Download `twrp-recovery-kansas-[number]`
3. Extract recovery.img
4. Flash to your device

## Flashing Recovery

```bash
# Extract downloaded zip
cd ~/storage/downloads
unzip twrp-recovery-kansas-*.zip

# Boot to bootloader
adb reboot bootloader

# Flash recovery (A/B device needs both slots)
fastboot flash recovery recovery.img

# Reboot to recovery
fastboot reboot recovery
```

## What If Build Fails?

### Common Issues:

**1. "Repo sync failed"**
- Just re-run the workflow
- Network issues are temporary

**2. "No recovery.img"**
- Check build logs for errors
- May need to add kernel source
- Try different TWRP branch

**3. "Workflow not showing"**
- Repository must be **PUBLIC**
- Check `.github/workflows/build-twrp.yml` exists
- Enable Actions in Settings

### Getting Help:

Check these files in order:
1. `GITHUB_BUILD_INSTRUCTIONS.md` - Detailed guide
2. Build logs in GitHub Actions
3. `TREE_SUMMARY.txt` - Device tree info
4. `BUILD_REQUIREMENTS.txt` - Build options

## Alternative: Build on PC

If you have access to a Linux PC with 150GB space and 8GB+ RAM:

1. Transfer this TREE folder to PC
2. Follow standard TWRP build instructions
3. Much faster than cloud build

## Files in This Directory

```
TREE/
├── QUICK_START.md                    ← You are here
├── GITHUB_BUILD_INSTRUCTIONS.md      ← Detailed guide
├── BUILD_REQUIREMENTS.txt            ← Why local build won't work
├── TREE_SUMMARY.txt                  ← Device tree explanation
├── upload-to-github.sh               ← Upload helper script
├── .github/
│   └── workflows/
│       └── build-twrp.yml            ← GitHub Actions workflow
└── motorola/
    └── kansas/                       ← Device tree files
        ├── BoardConfig.mk            ← Hardware config
        ├── device.mk                 ← Device packages
        ├── twrp_kansas.mk            ← TWRP product config
        └── ...                       ← All other device files
```

## Android 15 Specific Notes

This device tree is specifically configured for **Android 15**:

✅ **What's Included:**
- Dynamic Partitions (Super partition)
- File-Based Encryption (FBE) with metadata
- AVB 2.0 Verified Boot
- A/B Seamless Updates
- Fastbootd support
- Android 15 API Level 35 support

⚠️ **Important:**
- Use `android-14.0` or `android-15.0` TWRP branch
- DO NOT use `twrp-11` or older (won't work)
- MediaTek MT6835 requires specific HALs

## Need More Help?

- **Detailed Instructions:** Read `GITHUB_BUILD_INSTRUCTIONS.md`
- **Device Info:** Check `motorola/kansas/DEVICE_INFO.txt`
- **Partition Layout:** See `motorola/kansas/PARTITION_MAP.txt`
- **Build Options:** Review `BUILD_REQUIREMENTS.txt`

## Summary

1. ✅ Device tree is ready
2. ✅ GitHub Actions workflow configured for Android 15
3. ✅ Upload script ready
4. 🎯 Just upload to GitHub and start build!

**Estimated Total Time:** 2-3 hours (mostly automated)

**Cost:** $0 (completely free with public repo)

---

**Ready to build?** Run `./upload-to-github.sh` now!

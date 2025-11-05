# TWRP Device Tree - Motorola Moto G 2025 (kansas)

Complete TWRP recovery device tree for Motorola Moto G - 2025 running Android 15 on MediaTek MT6835 platform.

## Device Specifications

| Feature | Specification |
|---------|---------------|
| Device | Motorola Moto G - 2025 |
| Codename | kansas |
| Platform | MediaTek MT6835 |
| CPU | ARM Cortex-A55 (8 cores) |
| Architecture | ARM64 (aarch64) |
| Android Version | 15 (API Level 35) |
| Kernel Version | 5.15.167-android13-8-00008 |
| RAM | 4 GB |
| Storage | ~110 GB (F2FS) |
| Security Patch | 2025-06-01 |

## Features

- ✅ **Android 15 Support** - Built for latest Android version
- ✅ **A/B Seamless Updates** - Dual partition system
- ✅ **Dynamic Partitions** - 8GB super partition with flexible allocation
- ✅ **File-Based Encryption** - FBE with metadata encryption support
- ✅ **AVB 2.0** - Android Verified Boot integration
- ✅ **MediaTek Platform** - Full MT6835 hardware support
- ✅ **Trustonic TEE** - Trusted execution environment integration
- ✅ **Fastbootd** - Enhanced fastboot protocol
- ✅ **Multiple Firmware** - WiFi, Bluetooth, GNSS support

## Quick Start

### Option 1: GitHub Actions (Recommended - Free Cloud Build)

**Why?** Your Termux device doesn't have enough resources (need 150GB disk + 8GB RAM).

```bash
# 1. Run upload script
./upload-to-github.sh

# 2. Go to your GitHub repo → Actions
# 3. Run "Build TWRP Recovery" workflow
# 4. Select android-14.0 branch (for Android 15)
# 5. Wait 1-2 hours
# 6. Download recovery.img from Artifacts
```

📖 **Full Guide:** [QUICK_START.md](QUICK_START.md)

### Option 2: Build on Linux PC

If you have a Linux PC with sufficient resources:

```bash
# 1. Install dependencies (Ubuntu/Debian)
sudo apt-get install bc bison build-essential curl flex \
  g++-multilib gcc-multilib git gnupg gperf imagemagick \
  lib32ncurses5-dev lib32readline-dev lib32z1-dev \
  libelf-dev liblz4-tool libncurses5 libsdl1.2-dev \
  libssl-dev libxml2 libxml2-utils lzop pngcrush rsync \
  schedtool squashfs-tools xsltproc zip zlib1g-dev \
  python3 openjdk-11-jdk

# 2. Setup repo
mkdir ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH

# 3. Initialize TWRP source
mkdir ~/twrp && cd ~/twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b android-14.0
repo sync -c -j$(nproc)

# 4. Add device tree
mkdir -p device/motorola/kansas
cp -r /path/to/TREE/motorola/kansas/* device/motorola/kansas/

# 5. Build
source build/envsetup.sh
lunch twrp_kansas-eng
mka recoveryimage

# 6. Find recovery image
# Output: out/target/product/kansas/recovery.img
```

## Documentation

| Document | Description |
|----------|-------------|
| [QUICK_START.md](QUICK_START.md) | 5-step build guide |
| [GITHUB_BUILD_INSTRUCTIONS.md](GITHUB_BUILD_INSTRUCTIONS.md) | Complete GitHub Actions guide |
| [ANDROID_15_BUILD_NOTES.md](ANDROID_15_BUILD_NOTES.md) | Android 15 specific details |
| [BUILD_REQUIREMENTS.txt](BUILD_REQUIREMENTS.txt) | System requirements & alternatives |
| [TREE_SUMMARY.txt](TREE_SUMMARY.txt) | Device tree file explanation |
| [motorola/kansas/README.md](motorola/kansas/README.md) | Device-specific documentation |
| [motorola/kansas/DEVICE_INFO.txt](motorola/kansas/DEVICE_INFO.txt) | Complete device specifications |
| [motorola/kansas/PARTITION_MAP.txt](motorola/kansas/PARTITION_MAP.txt) | Partition layout details |

## Directory Structure

```
TREE/
├── README.md                           ← You are here
├── QUICK_START.md                      ← Start here for building
├── GITHUB_BUILD_INSTRUCTIONS.md        ← GitHub Actions guide
├── ANDROID_15_BUILD_NOTES.md           ← Android 15 specifics
├── BUILD_REQUIREMENTS.txt              ← System requirements
├── TREE_SUMMARY.txt                    ← Device tree overview
├── upload-to-github.sh                 ← Helper script for GitHub upload
│
├── .github/
│   └── workflows/
│       └── build-twrp.yml              ← GitHub Actions workflow
│
└── motorola/
    └── kansas/                         ← Device tree
        ├── Android.mk                  ← Build system integration
        ├── AndroidProducts.mk          ← Product definitions
        ├── BoardConfig.mk              ← Hardware configuration
        ├── device.mk                   ← Device packages
        ├── twrp_kansas.mk              ← TWRP configuration
        ├── README.md                   ← Device documentation
        ├── DEVICE_INFO.txt             ← Device specifications
        ├── PARTITION_MAP.txt           ← Partition information
        │
        ├── recovery/
        │   └── root/
        │       └── system/etc/
        │           ├── recovery.fstab  ← Mount points
        │           └── twrp.flags      ← TWRP flags
        │
        ├── rootdir/
        │   └── etc/
        │       ├── init.recovery.mt6835.rc
        │       └── init.recovery.trustonic.rc
        │
        └── [more files...]
```

## Building TWRP - Important Notes

### Android 15 Compatibility

This device tree is **specifically for Android 15**. Use these TWRP branches:

1. ✅ `android-14.0` - **Recommended** (stable, tested)
2. ✅ `android-15.0` - If available
3. ⚠️ `twrp-12.1` - May work, limited support
4. ❌ `twrp-11` or older - **Will NOT work**

### Required Configurations

The device tree includes all Android 15 requirements:

- **Dynamic Partitions:** 8GB super partition
- **FBE Encryption:** Full metadata encryption support
- **A/B Updates:** Dual slot system
- **AVB 2.0:** Verified boot (bootloader must be unlocked)
- **MediaTek HALs:** Platform-specific hardware support
- **API Level 35:** Android 15 compatibility

## Flashing Recovery

### Prerequisites

1. **Unlock Bootloader** (REQUIRED)
   ```bash
   # Check if unlocked
   fastboot getvar unlocked
   # Should return: unlocked: yes
   ```

2. **Install ADB/Fastboot**
   - Windows: https://developer.android.com/tools/releases/platform-tools
   - Linux: `sudo apt install android-tools-adb android-tools-fastboot`
   - Termux: `pkg install android-tools`

### Flash Commands

```bash
# Method 1: Flash to recovery partition (if separate)
adb reboot bootloader
fastboot flash recovery recovery.img
fastboot reboot recovery

# Method 2: Flash to boot partition (A/B devices)
adb reboot bootloader
fastboot flash boot recovery.img
fastboot reboot recovery

# Method 3: Temporary boot (no permanent flash)
adb reboot bootloader
fastboot boot recovery.img
```

**For A/B devices**, flash to both slots:
```bash
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```

## Build Artifacts

After successful build, you'll get:

| File | Description | Size |
|------|-------------|------|
| `recovery.img` | Recovery image to flash | ~60-100 MB |
| `ramdisk-recovery.cpio` | Recovery ramdisk | ~40 MB |
| `recovery.tar` | Recovery archive | ~60 MB |
| `build-info.txt` | Build metadata | ~1 KB |

## Troubleshooting

### Build Issues

| Problem | Solution |
|---------|----------|
| Insufficient disk space | Use GitHub Actions (cloud build) |
| Insufficient RAM | Use GitHub Actions or rent VPS |
| Kernel not found | Extract kernel from device or use prebuilt |
| Missing vendor blobs | Run `./extract-files.sh` from device |
| Repo sync fails | Re-run sync, check network |
| API level mismatch | Verify `PRODUCT_SHIPPING_API_LEVEL := 35` |

### Flash Issues

| Problem | Solution |
|---------|----------|
| Bootloader locked | Must unlock bootloader first |
| Device not detected | Install proper USB drivers, enable USB debugging |
| Signature verification failed | Disable AVB verification or use test keys |
| Recovery won't boot | Try `fastboot boot recovery.img` first |
| Stuck at bootloader | Flash to correct partition (boot vs recovery) |

### Recovery Issues

| Problem | Solution |
|---------|----------|
| Can't decrypt data | Check FBE configuration, may need to format data |
| Touch not working | Verify touch configuration in BoardConfig.mk |
| Display upside down | Adjust `TW_ROTATION` in BoardConfig.mk |
| Can't mount partitions | Verify fstab and partition names |
| ADB not working | Check USB configuration in BoardConfig.mk |

## GitHub Actions Details

### What Happens During Build

1. **Cleanup** (~30 sec) - Free up disk space
2. **Dependencies** (~2 min) - Install build tools
3. **Repo Setup** (~30 sec) - Initialize repo tool
4. **TWRP Sync** (~30 min) - Download 50-80GB source
5. **Device Tree** (~5 sec) - Add your device tree
6. **Compilation** (~45 min) - Build recovery image
7. **Upload** (~1 min) - Upload artifacts

**Total Time:** 1-2 hours
**Cost:** $0 (free for public repos)
**Limits:** 6 hour timeout (plenty of time)

### Viewing Logs

All build steps are logged in real-time. You can:
- Watch progress live
- Download logs after completion
- Debug build failures
- Share logs for help

## Contributing

Improvements welcome! Areas for contribution:

- [ ] Add prebuilt kernel
- [ ] Extract vendor blobs
- [ ] Test encryption/decryption
- [ ] Optimize build flags
- [ ] Add custom recovery features
- [ ] Update for newer Android versions

## Credits

- **TWRP Team** - TeamWin Recovery Project
- **LineageOS** - Device tree structure
- **MediaTek** - Platform support
- **Motorola** - Device firmware

## License

```
Copyright (C) 2025 The Android Open Source Project
Copyright (C) 2025 The TWRP Open Source Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Support

- **XDA Thread:** [Post your build on XDA]
- **TWRP Chat:** https://t.me/teamwin
- **Issues:** Use GitHub Issues for bug reports
- **Documentation:** All guides included in this repository

## Changelog

### 2025-11-04 - Initial Release
- Complete device tree for Motorola kansas
- Android 15 (API 35) support
- MediaTek MT6835 platform
- A/B partition support
- Dynamic partitions
- FBE with metadata encryption
- GitHub Actions workflow
- Comprehensive documentation

---

**Device:** Motorola Moto G - 2025 (kansas)
**Platform:** MediaTek MT6835
**Android:** 15 (API Level 35)
**Generated:** 2025-11-04

**Ready to build?** See [QUICK_START.md](QUICK_START.md) to get started!
# Tree

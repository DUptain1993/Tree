# Android 15 TWRP Build Notes

## Overview

This device tree is specifically designed for **Android 15** (API Level 35) on the Motorola Moto G - 2025 (kansas) with MediaTek MT6835 platform.

## Android 15 Specific Features

### 1. TWRP Branch Selection

For Android 15 devices, use these TWRP branches (in order of preference):

1. **`android-15.0`** (Recommended if available)
   - Official Android 15 support
   - Latest features and security patches
   - Best compatibility

2. **`android-14.0`** (Recommended fallback)
   - Stable and tested
   - Compatible with Android 15
   - Good support for dynamic partitions and FBE

3. **`twrp-12.1`** (Last resort)
   - May work but limited Android 15 support
   - Missing some newer features

❌ **DO NOT USE:**
- `twrp-11` or older - Will NOT work with Android 15
- `android-11` or older - Incompatible

### 2. Dynamic Partitions (Super)

Android 15 heavily relies on dynamic partitions:

```makefile
# Already configured in BoardConfig.mk
BOARD_SUPER_PARTITION_SIZE := 8589934592  # 8 GB
BOARD_SUPER_PARTITION_GROUPS := motorola_dynamic_partitions
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 8585740288
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product system_ext
```

**What this means:**
- Single super partition contains: system, vendor, product, system_ext
- Recovery must understand dynamic partition layout
- Backup/restore operations work differently
- Cannot resize partitions traditionally

**Required TWRP flags:**
```makefile
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_REPACKTOOLS := true
BOARD_USES_RECOVERY_AS_BOOT := false
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
```

### 3. File-Based Encryption (FBE)

Android 15 uses enhanced FBE with metadata encryption:

```makefile
# Encryption configuration
BOARD_USES_METADATA_PARTITION := true
BOARD_USES_QCOM_FBE_DECRYPTION := false  # MediaTek, not Qualcomm
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPTION := true
```

**Implications:**
- User data encrypted with FBE
- Metadata partition stores encryption keys
- TWRP needs proper FBE support to decrypt /data
- Must support direct boot (DE/CE storage)

### 4. AVB 2.0 (Android Verified Boot)

Android 15 enforces strict verified boot:

```makefile
BOARD_AVB_ENABLE := true
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
```

**What you need to know:**
- Recovery image must be signed
- Vbmeta partitions verify all images
- If bootloader locked, custom recovery won't boot
- Must unlock bootloader first

### 5. A/B Seamless Updates

This device uses A/B partitioning:

```makefile
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot
```

**Important notes:**
- Two copies of all system partitions (slot A and B)
- Recovery is part of boot image (not separate)
- Must flash to both slots for consistency
- OTA updates happen in background to inactive slot

### 6. MediaTek MT6835 Platform

Special considerations for MediaTek:

```makefile
TARGET_BOARD_PLATFORM := mt6835
BOARD_HAS_MTK_HARDWARE := true
MTK_HARDWARE := true
```

**MediaTek specifics:**
- Uses different bootloader than Qualcomm
- MediaTek preloader and LK bootloader
- Special modem partition (md1img)
- Connectivity firmware in separate partitions
- May need MediaTek-specific HALs

### 7. Kernel Configuration

Android 15 requires modern kernel:

```makefile
BOARD_KERNEL_VERSION := 5.15.167
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
```

**Kernel requirements:**
- Linux 5.10+ (this device: 5.15.167)
- GKI (Generic Kernel Image) support
- Dynamic partitions support
- F2FS filesystem support

### 8. Trustonic TEE

This device uses Trustonic Trusted Execution Environment:

```bash
# Init scripts
init.recovery.trustonic.rc
```

**TEE considerations:**
- Hardware-backed keystore
- Biometric authentication in TEE
- DRM support
- Must load TEE properly in recovery

## Build Process for Android 15

### 1. Source Selection

```bash
# Initialize with Android 15 compatible branch
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b android-14.0
```

### 2. Device Tree Placement

```bash
# Clone to proper location
mkdir -p device/motorola/kansas
cp -r motorola/kansas/* device/motorola/kansas/
```

### 3. Lunch Target

```bash
source build/envsetup.sh
lunch twrp_kansas-eng
```

### 4. Build Command

```bash
# For A/B devices, build recovery included in boot
mka recoveryimage

# Or if recovery is in boot partition
mka bootimage
```

## Common Android 15 Build Issues

### Issue 1: API Level Mismatch

**Error:**
```
error: PRODUCT_SHIPPING_API_LEVEL must be at least 34
```

**Fix:**
```makefile
# In device.mk
PRODUCT_SHIPPING_API_LEVEL := 35
```

### Issue 2: Dynamic Partition Errors

**Error:**
```
error: super partition size exceeds limit
```

**Fix:**
Check partition sizes in BoardConfig.mk:
```makefile
BOARD_SUPER_PARTITION_SIZE := 8589934592
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 8585740288  # Slightly less
```

### Issue 3: Vendor Mismatch

**Error:**
```
error: vendor security patch level mismatch
```

**Fix:**
```makefile
# In device.mk
VENDOR_SECURITY_PATCH := 2025-06-01
PLATFORM_SECURITY_PATCH := 2025-06-01
```

### Issue 4: Kernel Not Found

**Error:**
```
error: kernel image not found
```

**Fix Option 1 - Use prebuilt:**
```makefile
# In BoardConfig.mk
TARGET_PREBUILT_KERNEL := device/motorola/kansas/prebuilt/kernel
BOARD_PREBUILT_DTBOIMAGE := device/motorola/kansas/prebuilt/dtbo.img
```

**Fix Option 2 - Extract from device:**
```bash
# From your device
adb pull /dev/block/by-name/boot boot.img
# Extract kernel from boot.img using magiskboot or similar
```

### Issue 5: Missing Vendor Blobs

**Error:**
```
error: required libraries not found
```

**Fix:**
Extract vendor blobs from device:
```bash
cd device/motorola/kansas
./extract-files.sh
```

## Testing Recovery on Android 15

### Pre-Flash Checks

1. **Bootloader Status:**
   ```bash
   fastboot getvar unlocked
   # Should return: unlocked: yes
   ```

2. **Current Slot:**
   ```bash
   fastboot getvar current-slot
   # Returns: a or b
   ```

3. **Partition Layout:**
   ```bash
   fastboot getvar all
   # Check super partition size
   ```

### Flash Commands

```bash
# Boot to bootloader
adb reboot bootloader

# Flash recovery to both slots
fastboot flash recovery recovery.img
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img

# For A/B boot partition recovery
fastboot flash boot recovery.img

# Reboot to recovery
fastboot reboot recovery
```

### Testing Checklist

- [ ] Recovery boots successfully
- [ ] Touch screen works
- [ ] Display orientation correct
- [ ] Can decrypt /data (if encrypted)
- [ ] Can mount all partitions
- [ ] Backup works (system, data, boot)
- [ ] Restore works
- [ ] Can install zip files
- [ ] ADB works in recovery
- [ ] MTP works (file transfer)
- [ ] Can wipe partitions
- [ ] Can format data
- [ ] Fastbootd accessible
- [ ] Can switch slots (A/B)

## Performance Optimization

### 1. Use F2FS for Data

```makefile
# Already configured
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
```

F2FS is faster than ext4 on flash storage.

### 2. Enable Compression

```makefile
# For smaller recovery image
TW_NO_LEGACY_PROPS := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
```

### 3. Optimize Screen

```makefile
# Match device specs
TW_THEME := portrait_hdpi
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047
TW_DEFAULT_BRIGHTNESS := 1200
```

## Security Considerations

### 1. Encryption Keys

- Recovery needs proper FBE support
- Keys stored in metadata partition
- Must handle DE/CE storage correctly

### 2. Verified Boot

- Custom recovery disables AVB checks
- Keep bootloader unlocked for custom recovery
- Re-locking bootloader will brick device

### 3. SELinux

- Recovery typically runs permissive
- Production builds should be enforcing
- Adjust as needed in kernel cmdline

## Future Android Updates

### Preparing for Android 16+

- Monitor TWRP development for android-16.0 branch
- May need updated kernel (6.x series)
- Dynamic partition sizes may increase
- New security features may require updates

### Keeping Device Tree Updated

```bash
# Stay current with TWRP changes
git remote add twrp-common https://github.com/TeamWin/android_device_twrp_common
git fetch twrp-common
git merge twrp-common/android-15

# Update as needed
```

## Additional Resources

- **TWRP Device Requirements:** https://twrp.me/faq/whatcantwrpdo.html
- **Android 15 Changes:** https://source.android.com/docs/setup/about/android-15
- **MediaTek Dev:** https://docs.mediatek.com/
- **XDA Forums:** https://forum.xda-developers.com/

## Summary

Building TWRP for Android 15 requires:
- ✅ Correct TWRP branch (android-14.0 or android-15.0)
- ✅ Dynamic partition support
- ✅ FBE with metadata decryption
- ✅ A/B partition handling
- ✅ AVB 2.0 support
- ✅ Modern kernel (5.10+)
- ✅ Platform-specific HALs (MediaTek)

This device tree includes all necessary configurations for Android 15!

---

**Last Updated:** 2025-11-04
**Android Version:** 15 (API 35)
**Device:** Motorola Moto G - 2025 (kansas)
**Platform:** MediaTek MT6835

# Device Tree for Motorola Moto G - 2025 (Kansas)

## Device Specifications

| Feature                 | Specification                           |
| ----------------------- | :-------------------------------------- |
| Chipset                 | MediaTek MT6835                         |
| CPU                     | Octa-core (ARM Cortex-A55)              |
| GPU                     | Mali-G57                                |
| Memory                  | 4GB RAM                                 |
| Shipped Android Version | Android 15                              |
| Storage                 | 128GB                                   |
| Battery                 | Non-removable                           |
| Dimensions              | TBD                                     |
| Display                 | 280 DPI                                 |
| Rear Camera             | TBD                                     |
| Front Camera            | TBD                                     |
| Release Date            | 2025                                    |

## Device Picture

![Motorola Moto G - 2025](https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g-2025.jpg)

## Features

- **A/B Partitioning**: Seamless system updates
- **Dynamic Partitions**: Flexible partition sizing
- **File-Based Encryption**: AES-256-XTS encryption
- **MediaTek Platform**: MT6835 chipset

## Kernel

- **Kernel Version**: 5.15.167
- **Kernel Source**: Android13-5.15.167-android13-8-00008-g31975b884c4b
- **Compiler**: Clang 14.0.7

## Partition Layout

The device uses A/B partitioning with the following key partitions:

- **boot_a/boot_b**: 64 MB each
- **vendor_boot_a/vendor_boot_b**: 64 MB each
- **init_boot_a/init_boot_b**: 8 MB each
- **dtbo_a/dtbo_b**: 8 MB each
- **super**: 8 GB (contains system, system_ext, product, vendor, vendor_dlkm, odm)
- **userdata**: ~115 GB

## Building

To build TWRP for this device:

```bash
# Clone this repository
git clone https://github.com/yourusername/android_device_motorola_kansas device/motorola/kansas

# Clone vendor repository
git clone https://github.com/yourusername/android_vendor_motorola_kansas vendor/motorola/kansas

# Initialize TWRP build environment
. build/envsetup.sh

# Build TWRP recovery
lunch twrp_kansas-eng
mka recoveryimage
```

## Flashing

```bash
# Flash recovery to boot partition
fastboot flash boot_a recovery.img
fastboot flash boot_b recovery.img
```

## Copyright

```
Copyright (C) 2025 The Android Open Source Project
Copyright (C) 2025 The TWRP Open Source Project
```

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

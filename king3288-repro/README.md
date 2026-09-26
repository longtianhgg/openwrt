# KING3288 OpenWrt 25.12.5 build state

Current KING3288 source baseline:

- OpenWrt: 25.12.5
- Linux: 6.12.94
- Branch: `king3288-25.12.5`
- Target: `rockchip/armv7`
- Device: `king3288`

## Boot chain

The verified boot chain remains:

    SD inserted
      -> stock U-Boot 2017.09
      -> distro/extlinux
      -> SD p1 FAT32: zImage + rk3288-king3288.dtb
      -> SD p2 ext4 OpenWrt rootfs

    SD removed
      -> stock eMMC system

The stock U-Boot and eMMC installation are not modified.

## Restore feeds

From the OpenWrt source root:

    cp king3288-repro/feeds.conf feeds.conf
    ./scripts/feeds update -a
    ./scripts/feeds install -a

## Apply QuickStart compatibility patch

    git -C feeds/naspackages apply \
        ../../king3288-repro/patches/0001-quickstart-drop-mdadm-dependency.patch

## Restore pinned external packages

    ./king3288-repro/prepare-external.sh

Pinned external source revisions:

- OpenClash 0.47.156
  - commit: `c3a33c1d3407956fdf8f0e0b7c1a4c52e6ad9593`
- Argon
  - commit: `136eb5d42f30554e89cc737fd90f503909810660`

These generated package source directories are intentionally not tracked:

    package/luci-app-openclash/
    package/luci-theme-argon/

## KING3288 IDB/miniloader candidate

The tested binary build input is stored at:

    king3288-repro/blobs/king3288-old-idb-miniloader-candidate.bin

Size:

    105472 bytes

SHA256:

    84c08dd990738c1e935f86206a062aa75effc1148039328b5aa1722db818f8e3

It is written to the SD image starting at sector 64 for 206 sectors.

This binary was extracted from the original working KING3288 boot media and
has been physically verified on the current board.

It must not be described as the official or minimum Rockchip IDB image.
It is the currently tested KING3288 IDB/miniloader candidate.

## Restore build configuration

    cp king3288-repro/king3288.diffconfig .config
    make defconfig

Important current selections include:

- KING3288 device target
- ext4 rootfs
- 1024 MiB rootfs partition
- LuCI
- Argon
- QuickStart / iStore
- OpenClash 0.47.156
- Mihomo Meta 1.19.31

## Build

    make -j$(nproc)

Expected full SD image:

    bin/targets/rockchip/armv7/openwrt-rockchip-armv7-king3288-ext4-sdcard.img.gz

## GitHub Actions

Workflow:

    .github/workflows/king3288-build.yml

A push to branch:

    king3288-25.12.5

automatically starts the KING3288 cloud build.

The workflow:

1. verifies the committed IDB input;
2. restores pinned feeds;
3. applies the QuickStart compatibility patch;
4. restores pinned OpenClash and Argon sources;
5. restores the KING3288 diffconfig;
6. builds OpenWrt;
7. verifies the IDB embedded in the generated SD image;
8. uploads the firmware and manifest as GitHub Actions artifacts.

The whole-image SHA256 is not expected to be identical across different build
hosts. Kernel build metadata and locally generated APK signing keys can cause
binary differences between otherwise equivalent builds.

Do not commit local APK signing private keys.

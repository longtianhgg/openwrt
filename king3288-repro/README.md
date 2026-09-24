# KING3288 OpenWrt 25.12.5 reproducible build state

Board baseline:

- OpenWrt: 25.12.5
- Linux: 6.12.94
- Branch: king3288-25.12.5
- Board baseline commit: a55db13bb06a948579c1506f1c340cc6d6c7df5d

## Restore feeds

From OpenWrt source root:

    cp king3288-repro/feeds.conf feeds.conf
    ./scripts/feeds update -a
    ./scripts/feeds install -a

## Apply KING3288 userspace compatibility patch

    git -C feeds/naspackages apply \
        ../../king3288-repro/patches/0001-quickstart-drop-mdadm-dependency.patch

## Restore build configuration

    cp king3288-repro/king3288.diffconfig .config
    make defconfig

## Build

    make -j$(nproc)

Do not commit local APK signing private-key.pem.

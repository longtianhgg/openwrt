# SPDX-License-Identifier: GPL-2.0-only
#
# Rockchip RK3288 ARMv7 devices

KING3288_BOOT_PARTSIZE := 1024
KING3288_IDB := $(TOPDIR)/king3288-repro/blobs/king3288-old-idb-miniloader-candidate.bin
KING3288_FAT_BLOCK_SIZE := 1024
KING3288_FAT_BLOCKS := $(shell echo $$(($(KING3288_BOOT_PARTSIZE)*1024*1024/$(KING3288_FAT_BLOCK_SIZE))))

define Build/king3288-boot
rm -f $@
mkfs.fat -F 32 -n boot -C $@ $(KING3288_FAT_BLOCKS)
mcopy -i $@ $(IMAGE_KERNEL) ::/zImage
mcopy -i $@ $(LINUX_DIR)/arch/arm/boot/dts/rockchip/$(DEVICE_DTS).dtb ::/rk3288-king3288.dtb
mmd -i $@ ::/extlinux
mcopy -i $@ ./king3288-extlinux.conf ::/extlinux/extlinux.conf
endef

define Build/king3288-sdcard-img
mv $@ $@.boot
./gen_king3288_sdcard_img.sh \
        $@ $@.boot $(IMAGE_ROOTFS) \
        $(KING3288_BOOT_PARTSIZE) $(CONFIG_TARGET_ROOTFS_PARTSIZE) \
        $(KING3288_IDB)
rm -f $@.boot
endef

define Device/king3288
  DEVICE_MODEL := KING3288
  DEVICE_DTS := rk3288-king3288
  KERNEL := kernel-bin
  KERNEL_NAME := zImage
  FILESYSTEMS := ext4
  IMAGES := boot.img sdcard.img.gz
  IMAGE/boot.img := king3288-boot
  IMAGE/sdcard.img.gz := king3288-boot | king3288-sdcard-img | gzip
endef
TARGET_DEVICES += king3288

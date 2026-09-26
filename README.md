
本项目用于 KING3288 / RK3288 开发板的 OpenWrt 源码级适配。

当前基于：

- OpenWrt 25.12.5
- Linux 6.12.94
- Rockchip RK3288 ARMv7
- Cortex-A15
- 分支：`king3288-25.12.5`

目前已经完成板级适配、完整 SD 启动镜像以及 GitHub Actions 云端构建验证。

## 已完成的功能

目前已在 KING3288 实机验证：

- RK3288 四核 CPU、约 2GB RAM
- UART2 串口
- SD 卡与 eMMC
- ext4 rootfs
- GMAC RGMII
- RTL8211E PHY
- 100M / 1000M Ethernet
- ACT8846、SYR827、SYR828 电源管理
- TSADC CPU / GPU 温度监控
- LuCI Web 管理界面
- Argon 主题
- iStore / QuickStart
- OpenClash 0.47.156
- Mihomo Meta 1.19.31
- 完整可刷写 SD 卡镜像
- GitHub Actions 自动云编译

## 启动方式

当前适配保留原厂 U-Boot 和原厂 eMMC 系统，不修改原厂启动环境。

启动流程：

```text
插入 SD 卡
  ↓
原厂 U-Boot 2017.09
  ↓
distro / extlinux
  ↓
zImage + rk3288-king3288.dtb
  ↓
SD 卡 ext4 OpenWrt rootfs
```

不插 SD 卡时：

```text
原厂 U-Boot
  ↓
原厂 eMMC 系统
```

因此可以在不破坏原厂系统的情况下使用和测试 OpenWrt。

## 使用编译好的镜像

编译完成后的完整镜像为：

```text
openwrt-rockchip-armv7-king3288-ext4-sdcard.img.gz
```

解压并写入 SD 卡即可。

Linux 示例：

```bash
gzip -dc openwrt-rockchip-armv7-king3288-ext4-sdcard.img.gz \
  | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

其中 `/dev/sdX` 请替换为实际 SD 卡设备。

写入完成后，将 SD 卡插入 KING3288 并上电，原厂 U-Boot 会自动通过 extlinux 启动 OpenWrt。

当前新镜像 LAN 默认使用 DHCP Client，管理 IP 由上级路由器分配，可在上级路由器的 DHCP 客户端列表中查看。

## 本地编译

克隆仓库并切换分支：

```bash
git clone https://github.com/longtianhgg/openwrt.git
cd openwrt
git checkout king3288-25.12.5
```

恢复固定 feeds：

```bash
cp king3288-repro/feeds.conf feeds.conf
./scripts/feeds update -a
./scripts/feeds install -a
```

应用 QuickStart 兼容补丁：

```bash
git -C feeds/naspackages apply \
  ../../king3288-repro/patches/0001-quickstart-drop-mdadm-dependency.patch
```

恢复固定版本的 OpenClash 和 Argon：

```bash
./king3288-repro/prepare-external.sh
```

恢复 KING3288 配置：

```bash
cp king3288-repro/king3288.diffconfig .config
make defconfig
```

开始编译：

```bash
make -j$(nproc)
```

生成的完整 SD 镜像位于：

```text
bin/targets/rockchip/armv7/openwrt-rockchip-armv7-king3288-ext4-sdcard.img.gz
```

更详细的构建状态和固定版本信息见：

```text
king3288-repro/README.md
```

## GitHub Actions

仓库已经提供：

```text
.github/workflows/king3288-build.yml
```

向 `king3288-25.12.5` 分支提交相关修改后，可以自动完成：

```text
恢复 feeds
→ 恢复第三方源码
→ 恢复 KING3288 配置
→ 编译 OpenWrt
→ 生成完整 SD 镜像
→ 校验 IDB
→ 上传构建产物
```

当前 GitHub Actions 完整云端编译已经验证成功。

## IDB / Miniloader

当前 SD 镜像使用的 IDB/miniloader 位于：

```text
king3288-repro/blobs/king3288-old-idb-miniloader-candidate.bin
```

该文件从原厂可正常启动介质中提取，并已经在 KING3288 实机验证可用。

当前使用参数：

```text
Size:   105472 bytes
SHA256: 84c08dd990738c1e935f86206a062aa75effc1148039328b5aa1722db818f8e3
```

它是本项目当前验证使用的 IDB/miniloader，不代表 Rockchip 官方定义的最小 IDB 镜像。

## 已知问题

### 网络稳定性

目前主要未解决问题是持续网络负载下偶尔会出现明显丢包或短暂失联。


### eMMC 安装

当前只正式支持：

```text
SD 卡启动 OpenWrt
```

暂未提供：

- OpenWrt 安装到 eMMC
- 自动覆盖原厂系统
- 替换原厂 U-Boot

因此目前建议继续保留 SD 启动方式。


## 当前状态

目前项目已经完成：

```text
OpenWrt 25.12.5
    ↓
Linux 6.12.94
    ↓
RK3288 ARMv7
    ↓
KING3288 DTS
    ↓
Kernel + DTB + rootfs
    ↓
LuCI + Argon
    ↓
iStore + QuickStart
    ↓
OpenClash + Mihomo
    ↓
完整 SD 镜像
    ↓
原厂 U-Boot + extlinux
    ↓
SD 启动 OpenWrt
    ↓
GitHub Actions 云编译
```

![OpenWrt logo](include/logo.png)

OpenWrt Project is a Linux operating system targeting embedded devices. Instead
of trying to create a single, static firmware, OpenWrt provides a fully
writable filesystem with package management. This frees you from the
application selection and configuration provided by the vendor and allows you
to customize the device through the use of packages to suit any application.
For developers, OpenWrt is the framework to build an application without having
to build a complete firmware around it; for users this means the ability for
full customization, to use the device in ways never envisioned.

Sunshine!

## Download

Built firmware images are available for many architectures and come with a
package selection to be used as WiFi home router. To quickly find a factory
image usable to migrate from a vendor stock firmware to OpenWrt, try the
*Firmware Selector*.

* [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/)

If your device is supported, please follow the **Info** link to see install
instructions or consult the support resources listed below.

##

An advanced user may require additional or specific package. (Toolchain, SDK, ...) For everything else than simple firmware download, try the wiki download page:

* [OpenWrt Wiki Download](https://openwrt.org/downloads)

## Development

To build your own firmware you need a GNU/Linux, BSD or macOS system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Requirements

You need the following tools to compile OpenWrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
binutils bzip2 diff find flex gawk gcc-6+ getopt grep install libc-dev libz-dev
make4.1+ perl python3.8+ rsync subversion unzip which
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your target system.

### Related Repositories

The main repository uses multiple sub-repositories to manage packages of
different categories. All packages are installed via the OpenWrt package
manager called `opkg`. If you're looking to develop the web interface or port
packages to OpenWrt, please find the fitting repository below.

* [LuCI Web Interface](https://github.com/openwrt/luci): Modern and modular
  interface to control the device via a web browser.

* [OpenWrt Packages](https://github.com/openwrt/packages): Community repository
  of ported packages.

* [OpenWrt Routing](https://github.com/openwrt/routing): Packages specifically
  focused on (mesh) routing.

* [OpenWrt Video](https://github.com/openwrt/video): Packages specifically
  focused on display servers and clients (Xorg and Wayland).

## Support Information

For a list of supported devices see the [OpenWrt Hardware Database](https://openwrt.org/supported_devices)

### Documentation

* [Quick Start Guide](https://openwrt.org/docs/guide-quick-start/start)
* [User Guide](https://openwrt.org/docs/guide-user/start)
* [Developer Documentation](https://openwrt.org/docs/guide-developer/start)
* [Technical Reference](https://openwrt.org/docs/techref/start)

### Support Community

* [Forum](https://forum.openwrt.org): For usage, projects, discussions and hardware advise.
* [Support Chat](https://webchat.oftc.net/#openwrt): Channel `#openwrt` on **oftc.net**.

### Developer Community

* [Bug Reports](https://bugs.openwrt.org): Report bugs in OpenWrt
* [Dev Mailing List](https://lists.openwrt.org/mailman/listinfo/openwrt-devel): Send patches
* [Dev Chat](https://webchat.oftc.net/#openwrt-devel): Channel `#openwrt-devel` on **oftc.net**.

## License

OpenWrt is licensed under GPL-2.0

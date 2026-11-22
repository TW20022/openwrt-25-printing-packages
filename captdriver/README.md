# captdriver for OpenWrt / ImmortalWrt (aarch64)

将 GPLv3 开源项目 [cryptoluks/captdriver](https://github.com/cryptoluks/captdriver) 移植为 OpenWrt 打印包。
它直接通过 CUPS USB backend 与 Canon CAPT 打印机通信，**不需要** Canon 闭源 `ccpd` 守护进程，
也不需要 x86 / i386 运行库，可在 SK-D840N（aarch64_cortex-a53, musl）上交叉编译运行。

## 支持机型

- LBP2900 — 驱动标注 Works
- LBP3000 — 驱动标注 Experimental
- LBP3010 / LBP3018 / LBP3050、LBP3100 / LBP3108 / LBP3150、LBP6000 / LBP6018 同驱动支持
- **不支持** LBP7010C / LBP7018C（这两款只有 Canon 官方 x86 CAPT 驱动）

## 编译使用

1. 把本目录加入打印 feed 后刷新：`./scripts/feeds update printing && ./scripts/feeds install -a -p printing`
2. `make menuconfig` → Network → Printing → `captdriver`，或配置 `CONFIG_PACKAGE_captdriver=y`
3. 编译：`make package/feeds/printing/captdriver/compile`

安装后文件：

- `/usr/lib/cups/filter/rastertocapt`
- `/usr/share/cups/model/CanonLBP-2900-3000.ppd`

## 使用

内核需启用 `usblp`（`/dev/usb/lp0`），CUPS 需启用 USB backend。添加队列：

```sh
lpadmin -p LBP2900 -E -v "usb://Canon/LBP2900" -m CanonLBP-2900-3000.ppd
cupsenable LBP2900 && cupsaccept LBP2900
```

驱动靠 CUPS side-channel 读取 IEEE-1284 设备 ID 中的 `MODEL=` / `MDL=` 字段识别机型，
若打印机 ID 与内置表不一致会在 CUPS 错误日志打印 `unknown printer`。

## 设计说明

- 源码版本：master 分支 `0.1.4.1`，tarball SHA256 `d7a316e82a93b82ffb66815d170a1627c0c89f92c2437fe2abe4e9808d70b578`
- 编译不跑 autotools：直接把 src/ 下 9 个 C 文件用 `$(TARGET_CC)` 编译，链接 staging 目录中的 `-lcups`
- PPD 为随包手写的简化版，只保留 2900/3000 所需分辨率、纸张、省粉、手动双面（`cupsInteger0/2`）
- 原上游 `canon-lbp.drv` 需要目标机上的 `ppdc` 生成 PPD，不适用于交叉编译，故改为静态 PPD

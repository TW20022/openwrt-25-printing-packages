# openwrt25-printing-packages

OpenWrt **snapshots（master 分支）** 打印软件包 feed，在 `qualcommax/ipq807x`（aarch64_cortex-a53，GCC 14.4.0 + musl）交叉编译环境中 **20 个包目录全部实测编译通过**，产出 38 个 apk / 69 MB。

> 本仓库由 [`openwrt-24-printing-packages`](https://gitee.com/myiptvjs/openwrt-24-printing-packages) 演进而来。相对于 24.10 版，代码层面的增量集中在 **GCC 14 / Python 3.14 / musl** 三重升级带来的编译失败修复（hplip 的 014~019 号补丁，见第八节）。第四~七节的编译经验、CUPS/HP/Brother 使用说明与 24 版通用，仍然有效。

## 一、来源与合并规则

| 来源 | 处理方式 |
|---|---|
| [woniuzfb/openwrt-24-printing-packages](https://github.com/woniuzfb/openwrt-24-printing-packages) | `hplip` 3.25.6、`python3-dbus` 1.4.0 沿用其版本与补丁基线 |
| 本仓库 24.10 版 | 其余包原样继承；`hplip` 追加 014~019 六个 GCC 14 / Python 3.14 修复补丁，`PKG_RELEASE` 3 → 10 |

- 各包自带 `patches/` 全部保留，本地补丁分两类：**001~013** 是 24 时代的目标架构与安装路径修复（aarch64 链接、pyexecdir、backend 路径等），**014~019** 是 25 时代的编译器/解释器升级修复。
- 合并时按包名去重，同名包以本 feed 为准（feed 放在 `feeds.conf` 第一行，优先级高于官方 packages）。

## 二、软件与工具链版本

**编译环境**

| 项目 | 版本 |
|---|---|
| OpenWrt | snapshots（master），HEAD `c1bd42c9` |
| 目标平台 | `qualcommax/ipq807x`（`CONFIG_TARGET_BOARD="qualcommax"` / `CONFIG_TARGET_SUBTARGET="ipq807x"`） |
| 交叉工具链 | aarch64_cortex-a53，**GCC 14.4.0**，musl |
| 内核 | 6.18 |
| 构建主机 | Ubuntu 22.04 (WSL2)，4 vCPU / 3.8 GiB RAM |
| 包格式 | **apk**（`bin/packages/aarch64_cortex-a53/printing/*.apk`） |

> OpenWrt 25（master）已把包管理器从 opkg 换成 apk，产物是 `.apk` 而不是 `.ipk`；安装命令相应变为 `apk add`。

**包清单（20 个包目录全部编译通过，共 38 个 apk）**

| 包 | 版本 | 说明 |
|---|---|---|
| hplip / hplip-scan / hplip-ppds / hplip-tools | 3.25.6-**r10** | HP 打印/扫描，主包 + 扫描库 + PPD + 命令行工具 |
| cups / libcups / libcupsimage | 2.4.20-r1 | CUPS 打印服务（cupsd 守护进程 + libcups 库） |
| cups-client | 2.4.20-r1 | CUPS 客户端命令：`lp` `lpstat` `lpoptions` `cancel` `lpadmin` `lpinfo` `cupsfilter` `ipptool` `ippfind` |
| cups-bsd | 2.4.20-r1 | BSD 兼容命令：`lpr` `lpq` `lprm` `lpc` |
| cups-ppdc | 2.4.20-r1 | PPD 编译工具：`ppdc` `ppdi` `ppdmerge` `ppdpo` `ppdhtml`（可选） |
| cups-filters | 2.0.1-r1 | CUPS 过滤器（内含 `foomatic-rip`） |
| libcupsfilters / libppd | 2.1.1-r1 | CUPS 过滤库 / PPD 库 |
| ghostscript | 10.08.0-r1 | PostScript/PDF 解释器 |
| ghostscript-fonts-std | 8.11-r1 | 标准字体 |
| ghostscript-gnu-gs-fonts-other | 6.0-r1 | 额外字体（可选，默认不选） |
| poppler | 25.09.1-r1 | PDF 渲染库 |
| qpdf | 12.4.2-r1 | PDF 处理 |
| lcms2 | 2.15-r1 | 色彩管理 |
| libcairo | 1.16.0-r2 | 2D 绘图库 |
| libjbigkit | 2.2-r1 | JBIG 图像压缩 |
| cups-bjnp | 2.0.3-r1 | 佳能 BJNP 打印后端 |
| brlaser | 6-r1 | Brother 激光打印机驱动 |
| gutenprint-cups | 5.3.5-r1 | Gutenprint 驱动集合（已关闭 simplified PPD，每个型号只列一条） |
| splix | 2.0.1-r1 | Samsung SPL 打印机驱动 |
| liberation-fonts-ttf-* | 2.1.5-r1 | Liberation 字体（12 个 ttf 子包） |
| python3-dbus | 1.4.0-r2 | hplip 依赖 |

**本 feed 内但本次未产出 apk 的目录**

| 目录 | 原因 |
|---|---|
| `foo2zjs` | 目标 `.config` 中 `CONFIG_PACKAGE_foo2zjs` 未启用；需要在 menuconfig 里勾选后单独编译 |
| `box86` / `libarmeabi` / `brhl3040cncupswrapper` / `brhl3040cnfilter` | 用于在 ARM 上跑 i386 闭源 filter，需要 32 位 ARM 用户态；ipq807x 为纯 64 位 aarch64，不启用 |
| `cups-zh` / `tools` | 非 OpenWrt 包，是路由器端脚本与中文模板（见 7.9 / 7.10） |

## 三、编译方法

### 1. 准备环境

Ubuntu 22.04（本仓库在 WSL2 中构建）安装依赖：

```bash
sudo apt-get update
sudo apt-get install -y build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
  gettext git libncurses-dev libssl-dev python3-distutils rsync unzip zlib1g-dev file wget \
  xz-utils cpio python3 python3-pip python3-setuptools swig libelf-dev
```

### 2. 获取 OpenWrt 源码

```bash
git clone --depth 1 https://github.com/openwrt/openwrt.git
cd openwrt
```

> 本文实测的 HEAD 为 `c1bd42c9`。snapshots 是滚动分支，隔一段时间再编译可能遇到新的上游变更，建议记录自己的 HEAD。

### 3. 接入本 feed（必须放第一行）

```bash
cp feeds.conf.default feeds.conf
# 方式 A：本仓库为本地目录（推荐，改动即时生效）
sed -i '1i src-cpy printing /path/to/openwrt25-printing-packages' feeds.conf
# 方式 B：直接引用 git 仓库
# sed -i '1i src-git printing https://gitee.com/<你的账号>/openwrt25-printing-packages.git' feeds.conf
./scripts/feeds update -a
./scripts/feeds install -a
```

**feed 放第一行是强制的**：包名冲突时 feeds 按行序决定优先级，打印包必须优先于官方 packages feed（例如 `cups`、`poppler` 同名包）。

若遇到交叉编译时 cflags 被 pkgconf 过滤导致 configure 失败，修正 pkgconf 的透传：

```bash
sed -i '/--keep-system-cflags\|--keep-system-libs/d' tools/pkgconf/files/pkg-config
```

### 4. 基础配置

```bash
# 以官方 ipq807x 快照的 buildinfo 作为基线配置
wget https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/config.buildinfo -O .config

cat >> .config <<'EOF'
CONFIG_PACKAGE_hplip=y
CONFIG_PACKAGE_hplip-scan=y
CONFIG_PACKAGE_hplip-ppds=y
CONFIG_PACKAGE_hplip-tools=y
CONFIG_PACKAGE_cups=y
CONFIG_PACKAGE_cups-client=y
CONFIG_PACKAGE_cups-bsd=y
CONFIG_PACKAGE_cups-ppdc=y
CONFIG_PACKAGE_cups-filters=y
CONFIG_PACKAGE_ghostscript=y
CONFIG_PACKAGE_ghostscript-fonts-std=y
CONFIG_PACKAGE_poppler=y
CONFIG_PACKAGE_qpdf=y
CONFIG_PACKAGE_lcms2=y
CONFIG_PACKAGE_libcairo=y
CONFIG_PACKAGE_libcupsfilters=y
CONFIG_PACKAGE_libppd=y
CONFIG_PACKAGE_libjbigkit=y
CONFIG_PACKAGE_python3-dbus=y
CONFIG_PACKAGE_cups-bjnp=y
CONFIG_PACKAGE_brlaser=y
CONFIG_PACKAGE_gutenprint-cups=y
CONFIG_PACKAGE_splix=y
CONFIG_PACKAGE_kmod-usb-printer=y
EOF

make defconfig
```

> 低内存主机（3.8 GiB）建议关掉 BPF/LLVM 工具链，否则编 `tools/llvm-bpf` 会被 OOM 杀掉：
> `# CONFIG_BPF_TOOLCHAIN_BUILD_LLVM is not set` + `CONFIG_BPF_TOOLCHAIN_NONE=y` + `# CONFIG_USE_LLVM_BUILD is not set`。

### 5. 分阶段编译

```bash
make -j2 toolchain/compile V=s       # 工具链
make -j2 target/linux/compile V=s    # 内核（hplip 的 python 扩展需要 staging 头文件先就位）
make -j2 package/kernel/linux/compile V=s

# 批量编译整个打印组（目标按包目录名，不能按子包名）
for d in /path/to/openwrt25-printing-packages/*/; do
  n=$(basename "$d")
  [ -f "$d/Makefile" ] && echo "package/feeds/printing/$n/compile"
done | xargs -r make -j1 V=s
```

> **并行度**：hplip 在 `-j2` 下出现过 `.ver` 文件链接竞态（报 `local: *; };` syntax error），逐包编译统一用 `-j1` 最稳（本仓库即如此产出）。

产物：`bin/packages/aarch64_cortex-a53/printing/*.apk`

### 6. 安装到设备

```bash
apk update
apk add --allow-untrusted /tmp/printing/*.apk   # 本地编译、未签名的包
apk add hplip hplip-ppds hplip-tools            # 或者直接从已加入的源安装
hp-plugin -i     # 安装 HP 专有插件（GDI 机型需要）
hp-setup -i      # 连接打印机后配置
```

> 快照版 apk 有签名校验，本地编译的包要么 `--allow-untrusted`，要么用 `usign` 自建 key 后签名。

## 四、编译过程中踩过的坑

### 1. hplip：`cannot find -lImageProcessor`（aarch64 链接失败）★
- **现象**：`hpcups` 链接报 `skipping incompatible ./prnt/hpcups/libImageProcessor.so`，`Error 1`。
- **原因**：HP 只随源码分发 **x86/x86_64 预编译**的 `libImageProcessor.so`，无 aarch64 版本、无源码。
- **修复**：`hplip/patches/012-disable-imageprocessor-aarch64.patch` —— `hpcups_CXXFLAGS` 增加 `-DDISABLE_IMAGEPROCESSOR`、`hpcups_LDADD` 去掉 `-lImageProcessor`、`install-data-hook` 阻止拷贝 x86 库。源码中所有调用点都有该宏保护，仅 LJZJet（`ljzjstream`）路径使用，普通打印机不受影响。
- **复核结论（aarch64 实测，2026-10）**：补丁只改 `Makefile.am` 一行，`#ifdef DISABLE_IMAGEPROCESSOR` 分支是 HP 上游自带的。实测 hpcups 在此宏下仍能为 LJ 1020 产出**合法 ZJS 流**（`ESC E` + `@PJL ENTER LANGUAGE=ZJS` + `JZJZ` 魔数 + 数据块），编码路径未被打断。判别方法见 7.5「离线验证 ZJS 编码器」。

### 2. 低内存主机 OOM（`cc1plus: Killed`）
- **现象**：编译 `tools/llvm-bpf` 时 g++ 被杀，`toolchain/compile Error 2`。
- **原因**：3.8 GiB 内存 + `-j4` 编 LLVM/clang 大文件内存耗尽。
- **修复**：改 `-j1/-j2`；并**关闭 BPF/LLVM 工具链**（hplip 不需要）：
  ```
  # CONFIG_BPF_TOOLCHAIN_BUILD_LLVM is not set
  CONFIG_BPF_TOOLCHAIN_NONE=y
  # CONFIG_USE_LLVM_BUILD is not set
  ```
  注意 `CONFIG_USE_LLVM_BUILD` 才是 `tools/Makefile` 里的真正开关。

### 3. foo2zjs：`all-test Error 1`（构建机缺 `gs` / `dc`）
- **现象**：`Makefile:398: all-test Error 1`，提示 "gs is not installed"。
- **原因**：`all-test` 检测**构建主机**是否装了 ghostscript / GNU dc，用于本地生成测试页；交叉编译主流程并不需要。
- **修复**：`foo2zjs/patches/003-skip-host-gs-dc-check.patch`，把 `@if ! type gs`、`@if ! type dc`、`@if ! dc -V` 三处检查改为 `@if false`。

### 4. gutenprint 5.3.5：`Error 127`（host 工具路径失效）★★
- **现象 A**：`xml-stamp` 阶段执行 `build_dir/hostpkg/gutenprint-5.3.5/src/xml/printers/check_duplicate_printers.test`，报 No such file。
- **现象 B**：`xmli18n-tmp.h` 阶段执行 `build_dir/hostpkg/.../src/xml/extract-strings`，同样 127。
- **原因**：feed Makefile 用 SED 把目标树里的 `./check_duplicate_printers.test`、`./extract-strings` 改写为 **hostpkg 构建目录的绝对路径**；但 host 阶段完成后 OpenWrt host-build 机制会 `find | xargs rm -rf` 清空 hostpkg 构建目录（只留 stamp），目标编译时这些路径必然不存在。
- **修复**：注释掉 `check_duplicate_printers.test` 那条 SED（目标树 `--disable-test` 下本来就有本地 stub）；`extract-strings` 那条 SED 的替换目标改为 `true`（`xmli18n-tmp.h` 只在 dist 期生成 `po/POTFILES.in` 用，`--disable-nls` 下全树无人 include）。

### 5. gutenprint：CUPS 里每个型号出现两条（`Simplified` 不是"简体中文"）★
- **现象**：CUPS「添加打印机」的型号列表里，同一个打印机出现两份，其中一份名称后缀是 `Simplified`，容易被误认为是"简体中文"。
- **真相**：这是 gutenprint 的**简化版 PPD**（选项精简，给新手用），与语言无关。源码 `gutenprint.c: list_ppds()` 对每个型号固定输出 `/expert` 一条，若编译时定义了 `GENERATE_SIMPLIFIED_PPDS` 再额外输出 `/simple` 一条，两条的 CUPS 语言字段都硬编码为 `"en"`：
  ```c
  printf("\"%s://%s/expert\" ... \"%s\"", scheme, driver, "en", ...);
  #ifdef GENERATE_SIMPLIFIED_PPDS
  printf("\"%s://%s/simple\" ... \"%s" VERSION " Simplified\"", ...);
  #endif
  ```
- **触发条件**：feed Makefile 里的 `--enable-simplified-cups-ppds`（对应 `BUILD_SIMPLE_PPDS=-DGENERATE_SIMPLIFIED_PPDS`）。
- **修复**：改为 `--disable-simplified-cups-ppds`，重编后驱动二进制里只剩 `/expert"`、不再有 `/simple"`，CUPS 列表每个型号只出现一条。
- **附注**：本 feed 的 gutenprint 包**不打包任何 PPD**（`install` 段故意不拷 `/usr/share/cups/model`），PPD 由 `gutenprint.5.3` 驱动 / `cups-genppd.5.3` 在运行时生成；型号名来自 XML，官方明确要求型号名不翻译，因此列表显示为英文属正常。

### 6. feeds 源与镜像
- `git.openwrt.org` 国内直连常在 `fetch-pack: unexpected disconnect` 处失败。解决办法：把 `feeds.conf` 里的官方 git 全部指向 GitHub 镜像并保留原 commit 锁定：
  ```
  src-git packages  https://gh-proxy.com/https://github.com/openwrt/packages.git^<commit>
  src-git luci      https://gh-proxy.com/https://github.com/openwrt/luci.git^<commit>
  src-git routing   https://gh-proxy.com/https://github.com/openwrt/routing.git^<commit>
  src-git telephony https://gh-proxy.com/https://github.com/openwrt/telephony.git^<commit>
  ```
- GitHub 直连不稳时统一用 `https://gh-proxy.com/https://github.com/...` 前缀（`git clone`、`wget`、raw 文件都适用）。

### 7. 配置与 make 目标的坑
- **子包 ≠ 编译目标**：`make package/liberation-fonts-ttf-LiberationMono/compile` 会报 `No rule to make target`。make 目标必须用**包目录名**（`package/feeds/printing/liberation-fonts/compile`），一个目录可含多个子包。
- **子包必须逐个启用**：hplip 有 4 个子包（hplip / hplip-scan / hplip-ppds / hplip-tools），`CONFIG_PACKAGE_hplip=y` 只产主包，扫描、PPD、`hp-setup` 命令行工具都在子包里。
- **符号名与目录名不一致**：`gutenprint` 的可选符号实际是 `CONFIG_PACKAGE_gutenprint-cups`；`liberation-fonts` 拆成 12 个 `-ttf-*` 子包；`ghostscript-gnu-gs-fonts` 只有 `-other` 一个可选子包。写错符号时 `make defconfig` 会静默丢弃，务必 `grep .config` 复查。
- **架构切换必须 `make dirclean`**：从 x86/64 切到 ipq807x 时，旧工具链和 build_dir 会污染结果。

### 8. Windows/WSL 环境（可选参考）
- 本机为 Windows Server 2022（build 20348），内置 `wsl.exe` 只是引导器（不支持 `--import`），WSL 3.x 安装包不支持 Server 2022（exit 83），改用 **WSL 2.7.14 MSI** 后正常。
- WSL 功能启用后必须**重启**才能生效。
- 在 Git Bash 里调用 `msiexec` / `dism` 会被 MSYS 路径转换破坏参数，改用 PowerShell 或 `MSYS_NO_PATHCONV=1`。

## 五、目录结构

```
.
├── brhl3040cncupswrapper/     # 各打印包目录，每个含 Makefile 与可选 patches/
├── brhl3040cnfilter/
├── brlaser/
├── cups/
├── cups-bjnp/
├── cups-filters/
├── foo2zjs/patches/003-skip-host-gs-dc-check.patch
├── ghostscript/
├── ghostscript-fonts-std/
├── ghostscript-gnu-gs-fonts/
├── gutenprint/               # Makefile 内含本地修复（见 4.4）
├── hplip/patches/            # 001~019：001~013 架构/路径修复，014~019 GCC14/Python3.14 修复
├── lcms2/
├── liberation-fonts/
├── libcairo/
├── libcupsfilters/
├── libjbigkit/
├── libppd/
├── poppler/
├── python3-dbus/
├── qpdf/
├── splix/
├── cups-zh/                  # CUPS Web 中文界面包（非 OpenWrt 包，见 7.9）
├── tools/                    # 路由器端排障脚本（链路自测 / 固件下发 / raster 诊断，见 7.10）
└── README.md
```

## 六、已知限制

- `libImageProcessor` 相关功能（部分 LJZJet 系列）在 aarch64 上不可用。
- **`foomatic-filters` 已从本 feed 移除**：cups-filters 2.x 自带 `foomatic-rip`（`/usr/bin/foomatic-rip` 与 `/usr/lib/cups/filter/foomatic-rip`），独立包冗余；且 TW20022 版该包缺少 `install` 段，OpenWrt 会以 `package has no install section` 跳过、根本不产出 apk。
- `ghostscript-gnu-gs-fonts-other`（额外字体）默认不启用。
- 编译验证环境为 4 核 / 3.8 GiB 内存，`-j2` 为稳妥值；内存 ≥8 GiB 可用 `-j$(nproc)` 提速。

## 七、路由器端安装与使用

### 7.1 安装顺序

```sh
apk update
apk add cups cups-filters ghostscript qpdf poppler      # 打印底座
apk add hplip hplip-ppds hplip-tools                    # hplip 三件套（主包会自动拉依赖）
apk add hplip-scan                                      # 需要扫描时再装（引入 libsane）
```

包体参考：`hplip` 9.4 MB（装在设备上约 16 MB）、`hplip-ppds` 17 MB（1370 个 PPD，空间紧张可只解压需要的型号）、`hplip-tools` 0.5 MB。

### 7.2 启动服务并添加打印机

```sh
/etc/init.d/cupsd enable && /etc/init.d/cupsd start
hp-probe -b usb                       # 列出 USB 上的 HP 设备
hp-makeuri <bus>:<dev>                # 取得设备 URI，如 hp:/usb/HP_LaserJet_1020?serial=000000000WA...
hp-setup -i                          # 交互式建队列（无 GUI，务必带 -i）
```

`hp-setup -i` 会依次询问：连接方式（usb）→ 型号 → PPD → 队列名，最后自动调用 CUPS 接口创建队列。也可以直接在 CUPS 网页 `http://<路由器IP>:631` 或 LuCI 的「网络打印机」里添加，设备 URI 填 `hp-makeuri` 给出的那一串（网页管理需先配好管理员与访问控制，见 7.8）。

### 7.3 hplip-tools 里有什么

`hplip-tools` 提供 37 个命令，常用：

| 命令 | 用途 |
|---|---|
| `hp-setup` | 建队列（`-i` 交互模式） |
| `hp-plugin` | 安装 HP 专有插件（GDI 机型必需，见 7.5） |
| `hp-firmware` | 手动给设备刷固件（`-y3 -s <bus>:<dev>` 静默） |
| `hp-probe` / `hp-makeuri` | 探测设备 / 生成设备 URI |
| `hp-info` / `hp-levels` | 设备信息 / 墨粉余量 |
| `hp-check` / `hp-doctor` | 依赖与配置自检 |
| `hp-clean` / `hp-align` / `hp-testpage` | 清洗 / 校准 / 测试页 |
| `hp-config_usb_printer` | 热插拔时被调用，内部做插件检测 + 固件下发 |

### 7.4 USB 热插拔脚本做了什么

`/etc/hotplug.d/usb/10-hp-printer`（主包自带，`conffiles` 保护）在 USB `bind` 事件时：

1. 只处理 HP 设备（`PRODUCT` 前缀 `3f0/`）且接口类为 `07/01`（打印机类）；
2. 关闭该设备的 USB autosuspend（避免打印中途休眠掉线）；
3. 给 `/dev/lpX` 设 `root:nogroup 0664`；
4. 若 `/var/lib/hp/hplip.state` 不存在且 `~/.hplip/plugin_tmp/installPlugin.py` 在，则执行插件安装（本 feed 的 `010-fix-hplip-plugin-install.patch` 支持这种预解压安装）；
5. 调 `hp-config_usb_printer <BUSNUM>:<DEVNUM>`——**这一步才是决定要不要刷固件的地方**。

### 7.5 GDI / 主机型打印机（LaserJet 1020、P1005 等）的固件问题

> **实测设备修正**：本 feed 实际测试机是 **HP LaserJet 3050**（`03f0:3217`，MFP，标准 PCL5 机型），`models.dat` 里 `plugin=0`、`fw-download=False`，插上即枚举为 `1-1:1.0 class=07`（printer）+ `1-1:1.1 class=ff`（扫描件），**既不装插件也不刷固件**，`hp-setup -i` 直接建队列就能打。先确认自己的机型属于哪一类：
>
> ```sh
> sed -n '/^\[hp_laserjet_1020\]/,/^\[/p' /usr/share/hplip/data/models/models.dat | grep -E 'plugin|fw-download'
> # plugin=0 → 到此为止；plugin=1 + fw-download=True 才是下面要折腾的机型
> ```

这类机器（1000/1005/1018/1020/1022、P1005/P1006/P1007/P1008/P1009/P1505、P1102/P1566 等）是"无固件裸机"：冷启动后 USB 里只有引导程序，**必须先下发固件才会变成正常打印机**，断电后每次都要重来。

- 数据侧标记：`models.dat` 里这些型号是 `plugin=1`、`plugin-reason=1`、`fw-download=True`。
- 固件不在 hplip 包里：本 feed 的 `hplip` apk **0 个固件文件**（`data/` 下只有 ldl/localization/models/pcl/ps）。
- 固件只在 HP 专有插件里：`hplip-3.25.6-plugin.run`（11.5 MB，SHA256 `0cd770036532a2d706c0f449ee1e3ef9b4de7b6cea5aaf2e76fe2da3f97f6ffc`）内含 13 个 `*.fw.gz`，其中 `hp_laserjet_1020.fw.gz` 仅 70 KB、`hp_laserjet_p1005.fw.gz` 153 KB。

**结论：需要装一次插件，但不需要每次手动刷固件。**

`hp-config_usb_printer` 的逻辑（`config_usb_printer.py`）：先查插件状态，未安装则打印
`HP Device plugin's are not installed. Please install plugin's using hp-plugin command.` 并跳过；
已安装且 `fw-download=True` 才执行 `hp-firmware -y3 -s <busnum>:<devnum>`（**三位补零的 USB ID**，来自 `lsusb`，不是 sysfs 的 `1-1:1.0`）自动下发。因此在热插拔脚本生效之前，必须先满足插件这一环。

插件安装（二选一）：

```sh
# A. 联网：直接让 hp-plugin 下载（需访问 hplip.sf.net / openprinting.org）
hp-plugin -i

# B. 离线：把 hplip-3.25.6-plugin.run 传到路由器后指定路径安装
hp-plugin -i -p /tmp/hplip-3.25.6-plugin.run

# B'. 离线且不想装 32 MB 插件的"只放固件"做法（够 1020/P1005 打印用）
mkdir -p /usr/share/hplip/data/firmware
cp hp_laserjet_1020.fw.gz /usr/share/hplip/data/firmware/
hp-config_usb_printer 001:004       # 或 hp-firmware -y3 -s 001:004（busnum:devnum）
```

> 说明：本 feed 编译时 `hpijs-install=no`、只保留 hpcups，LJ 1020 这类 ZJS 机型的编码器在 hpcups 内（`LJZjStream.cpp`），所以插件对它们的主要作用就是**携带固件**，用 B' 即可；`bb_*` 后端与扫描插件才需要完整插件。

**装插件踩过的两个坑**

1. `error: Plug-in GPG file [.../plugin.run.asc] download failed` —— `-p` 指定本地 `.run` 时，hp-plugin 会去找**同目录同名**的 `.asc`。缺 `.asc` 只是警告，随后问 `Do you still want to install the plug-in? (y=yes, n=no*, q=quit)`，**默认 no，必须手动敲 `y`**。
2. `error: GPG command not found` —— 补上 `.asc` 反而卡死（OpenWrt 没有 `gnupg`，`hp-plugin` 2.1 也没有跳过验签的开关）。正确做法是**把 `.asc` 挪走**退回第 1 条，用 sha256 代替验签：
   ```sh
   sha256sum /tmp/hplip-3.25.6-plugin.run   # 应等于 0cd7700...7f6ffc
   mv /tmp/hplip-3.25.6-plugin.run.asc /tmp/plugin.run.asc.bak
   hp-plugin -i -p /tmp/hplip-3.25.6-plugin.run
   ```
   若 `~/.hplip/plugin_tmp/` 已有上次解压结果，会跳过解压直接 `Executing installPlugin.py` → `Done.`（没有 license 提示），属正常。

**装成功长什么样**

```sh
ls -l /usr/share/hplip/data/firmware/*.fw.gz   # 13 个：1000/1005_series/1018/1020/P1005~P1009/P1505/P1102/P1102w/P1566
ls /root/.hplip/plugin_tmp/*.so | head         # bb_escl-arm64.so 等 aarch64 后端在
```

**坑三：`/var` 是 tmpfs，插件状态随重启丢失** ★★

状态文件落在 `/var/lib/hp/hplip.state`（`/var` 软链到 `/tmp`），内容三行 `[plugin]` / `installed = 1` / `eula = 1` / `version = 3.25.6`。断电即丢，表现为"插件装过、但每次冷启动还得手动刷固件"。修复：复制到 `/etc` 再软链回去，并让 `rc.local` 在 tmpfs 重建后补链：

```sh
mkdir -p /etc/hplip && cp /var/lib/hp/hplip.state /etc/hplip.state && chmod 644 /etc/hplip.state
rm -f /var/lib/hp/hplip.state && ln -s /etc/hplip.state /var/lib/hp/hplip.state
sed -i '/^exit 0/i [ -e /var/lib/hp/hplip.state ] || { mkdir -p /var/lib/hp; ln -sf /etc/hplip.state /var/lib/hp/hplip.state; }' /etc/rc.local
```

**离线验证 ZJS 编码器（没有 1020 硬件也能做）★**

`hp-laserjet_1020.ppd.gz` 的 `cupsFilter` 是 `application/vnd.cups-raster 0 hpcups`，手动跑两段过滤器就能拿到真实打印数据流（绕开 cupsd 和 `file:` 后端的限制）：

```sh
cd /tmp
printf '%%!PS\n/Helvetica findfont 20 scalefont setfont 72 700 moveto (test) show showpage\n' > page.ps
zcat /usr/share/ppd/HP/hp-laserjet_1020.ppd.gz > p1020.ppd
export PPD=/tmp/p1020.ppd CUPS_DATADIR=/usr/share/cups
/usr/lib/cups/filter/gstoraster 1 root page 1 "PageSize=A4 Resolution=600dpi" page.ps > page.raster 2>gs.err
/usr/lib/cups/filter/hpcups     1 root page 1 "PageSize=A4 Resolution=600dpi" page.raster > h.zjs 2>hpc.err
ls -l page.raster h.zjs; cat hpc.err; hexdump -C -n 48 h.zjs
```

实测三组数据（aarch64，`DISABLE_IMAGEPROCESSOR` 生效，单页 A4 600dpi）：

| 页面内容 | `x.raster` | `hpcups` 产出 | `foo2zjs` 产出 |
|---|---|---|---|
| 实心黑块（`rectfill`） | 3941714 | **503 B** | — |
| 一行文字 + 一条线 | 3941714 | **1495 B** | — |
| 5000 条随机短线（噪点） | 3941714 | **8791 B** | **9371 B** |

判读要点：

- `raster` 体积恒定（3941714）是因为它这个配置下是**未压缩定长位图**（621 B/行 × 6347 行），只由页面尺寸决定，**不能用来看内容**。
- ZJS 是**行间差分**编码，所以纯色页反而最小（行间差分≈0），文字页中等、噪点页最大——**体积随内容复杂度单调增长**，说明编码器真的在编码。
- 噪点页 hpcups 8791 B vs foo2zjs 9371 B，仅差 6%，与已知正确实现同量级 → **hpcups 的 ZJS 路径在 aarch64 上可用**。

判据：0 字节、或 `hpc.err` 提到 `ImageProcessor`、或噪点页仍在 1 KB 级 → 编码器不可用，改走 7.6 的 foo2zjs。正常时 `hpc.err` 只有 `PAGE: 1 1`。

噪点页比纯色页更能暴露问题，验证时优先用它。`foo2zjs` 的参考值来自其 PPD 的 `FoomaticRIPCommandLine`（`foo2zjs-wrapper -z1 -P -L0 %A`）：

```sh
cat > noise.ps <<'EOF'
%!PS-Adobe-3.0
0 setlinewidth
1 1 5000 { pop rand 500 mod 40 add rand 780 mod 40 add moveto rand 100 mod 8 add 0 rlineto stroke } for
showpage
EOF
foo2zjs-wrapper -z1 -P -L0 noise.ps > noise_f.zjs 2> f.err
```

附注：`gstoraster` 单独运行时**退出会 SIGSEGV**（raster 已完整写出，CUPS 管线内实测不影响出纸）。

### 7.6 另一条路：foo2zjs（全开源，已在本 feed 内）

> 定位说明：本 feed 的 hpcups 已实测能为 LJ 1020 产出合法 ZJS 流（见 7.5），**正常情况下不需要切到这条路**；foo2zjs 作为"hpcups 输出异常"或"不想装 HP 专有插件"时的备选。

`foo2zjs` apk 自带 `HP-LaserJet_1020.ppd.gz` 与固件转换工具 `arm2hpdl`，同样支持 1005/1018/1020/1022/P1005/P1006/P1505 等。但它**不带固件本体**（`sihp1020.dl` 需要自行获取），安装后需自建 hotplug 规则把 `.dl` 写进 `/dev/usb/lp0`。适合不想引入 HP 专有插件的场景。

#### 7.6.1 走 foo2zjs 时固件怎么加载

先厘清一件事：**灌固件和用哪个驱动打印是两条独立的线，可以混搭**。

| | 可选项 |
|---|---|
| 灌固件 | `hp-firmware`（libusb 直写）／`cat *.dl > /dev/usb/lp0`（经 usblp） |
| 打印 | `hpcups`（hplip 链）／`foo2zjs`（foomatic-rip + foo2zjs-wrapper） |

所以"打印走 foo2zjs、固件用 hplip 的 `hp-firmware` 灌"完全合法，插件已在位时最省事；反过来，纯 foo2zjs 环境（不装 hplip）就得自己生成 `.dl` 并挂 hotplug。

**固件本体三个来源**，按拿到手的难易排序：

```sh
# ① 已有 hplip 插件里的 .fw.gz（本 feed 实测就在这个位置，70412 字节）
ls /usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz

# ② foo2zjs 上游取原始 .img，再转 .dl
getweb 1020                                   # 需要 wget；产物是 sihp1020.img
arm2hpdl sihp1020.img > sihp1020.dl

# ③ 别处已有的成品 .dl（1020 与 1020plus 通用）
```

注意 **hplip 的 `.fw.gz` 和 `getweb` 的 `.img` 是两种不同的封装，处理方式不一样**：

| 来源 | 内部结构 | 正确做法 |
|---|---|---|
| hplip 的 `hp_laserjet_1020.fw.gz` | gzip 压缩的**裸 `.dl`** | `zcat` 解压即成品 |
| `getweb 1020` 的 `sihp1020.img` | HP 官方上传格式，内部有 `FW` 头 | `arm2hpdl` 剥头才成 `.dl` |

**别把 `.fw.gz` 喂给 `arm2hpdl`**。它只认 `FW` 头，实测直接喂、`zcat` 后喂都是 **0 字节** —— 脚本早期版本那句 `[FAIL] arm2hpdl 两种输入方式都失败` 就是这么来的（2026-11-01 真机复现，机型 3050 上跑的体检）。正确命令：

```sh
mkdir -p /lib/firmware/hp

# 从 hplip 插件取（最省事，插件装过就有）
zcat /usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz > /lib/firmware/hp/sihp1020.dl

# 或从 getweb 的 .img 转
getweb 1020 && arm2hpdl sihp1020.img > /lib/firmware/hp/sihp1020.dl
```

成品要自检三条：**大小过 10240 字节**（0 字节就是转换失败）、**首字节不能是 `1f 8b`**（那是 gzip 没解压）、**前 256 字节不能几乎全是可打印文本**（那是 hplip 头没剥掉）。`/lib/firmware` 在 OpenWrt 上落在 overlay 的 upper 层，可写且重启不丢。

**1020 的固件只在 RAM 里，断电即失效** —— 所以 hotplug 不是可选项。OpenWrt 没有 udev，规则放 `/etc/hotplug.d/usb/`（`/var` 是 tmpfs，放那里重启就没）：

```sh
#!/bin/sh
# /etc/hotplug.d/usb/20-hp1020-fw
[ "$ACTION" = "add" ] || exit 0
case "$PRODUCT" in 3f0/2b17/*|3f0/2b17) ;; *) exit 0 ;; esac
FW=/lib/firmware/hp/sihp1020.dl
[ -s "$FW" ] || exit 0
i=0
while [ $i -lt 30 ]; do
  for lp in /dev/usb/lp*; do
    [ -c "$lp" ] || continue
    # device/ 是 interface 目录（1-1:1.0），idVendor 在父目录，必须逐级往上找
    vp=""
    for d in "/sys/class/usb/${lp##*/}/device" "/sys/class/usb/${lp##*/}/device/.."; do
      [ -r "$d/idVendor" ] || continue
      vp="$(cat "$d/idVendor"):$(cat "$d/idProduct")"; break
    done
    [ "$vp" = "03f0:2b17" ] || continue
    # 已加载固件的设备能读出 IEEE-1284 ID，别重复灌
    command -v usb_printerid >/dev/null && case "$(usb_printerid "$lp" 2>/dev/null)" in
      *MFG:*|*CMD:*) exit 0 ;;
    esac
    cat "$FW" > "$lp" && logger -t hp1020fw "firmware sent to $lp"
    exit 0
  done
  sleep 0.1; i=$((i+1))
done
logger -t hp1020fw "no /dev/usb/lp* for 03f0:2b17 (装 kmod-usb-printer 了吗？)"
```

前置条件就两条：`kmod-usb-printer`（提供 usblp 与 `/dev/usb/lp*`）、`foo2zjs`（提供 `arm2hpdl` 与 `usb_printerid`）。

上面这一整套（找固件、转换、自检、装 hotplug、灌一次并验证）已固化成脚本：

```sh
scp tools/foo2zjs-fw-setup.sh root@<路由器>:/tmp/
sh /tmp/foo2zjs-fw-setup.sh            # 只体检：列固件源、试转换、看 usblp、查 1020 在不在
sh /tmp/foo2zjs-fw-setup.sh --install  # 生成 .dl + 装 hotplug 规则
sh /tmp/foo2zjs-fw-setup.sh --now      # 再立刻给当前插着的机器灌一次
sh /tmp/foo2zjs-fw-setup.sh --hplip    # 改用 hp-firmware -y3 -s <bus:dev> 灌（插件已装时首选）
sh /tmp/foo2zjs-fw-setup.sh --remove   # 卸载 hotplug 规则
```

脚本第 4 步会打一个决定性判据：**固件灌进去后设备会重新枚举，若新身份下 `/dev/usb/lp*` 消失，说明 usblp 不再绑定，foo2zjs 这条路就走不通**（它只能经 `/dev/usb/lp0` 发数据），应改回 hplip 的 hp backend。这个结论没法离线推断，只有真机能给。

**踩坑记录：`pdf-to-ps exited with status 9`**。CUPS 2.4 + cups-filters 2.x 的内部工作流是 PDF 优先，foomatic-rip 要吃 `application/vnd.cups-postscript`，于是 cupsd 会先 `ps → pdf`（`ps-to-pdf`）再 `pdf → ps`（`pdf-to-ps`）转回来。这台机上第二步返回 9，导致作业「completed」但 backend 只拿到空数据。表现为：**所有 foomatic-rip 型 PPD（整个 foo2zjs 家族）在 cupsd 里都出不了纸**，而 hpcups / brlaser / splix 不受影响（它们从 `application/vnd.cups-raster` 起，走 `pdftoraster`，不经过 `pdf-to-ps`）。定位于：

```sh
ls -l /usr/lib/cups/filter/pdf-to-ps        # cups-filters 多呼叫二进制的入口
ls -l /usr/lib/cups/filter/pdftops
/usr/sbin/cupsfilter -p /usr/share/cups/model/HP-LaserJet_1020.ppd.gz \
  -i application/postscript /etc/hostname > /tmp/o.zjs 2> /tmp/o.err ; echo rc=$?
grep -iE 'pdf-to-ps|pdftops|status 9' /tmp/o.err
```

真机上这一步修不好就别在 foo2zjs 上耗 —— hpcups 那条链已实测能为 1020 产出合法 ZJS 流，foo2zjs 更适合当"不经 CUPS 直接生成数据流"的工具（`test-foo2zjs-1020.sh` 第 2 步就是这么验的）。


### 7.7 Brother 三个包怎么用

| 包 | 内容 | 适用 |
|---|---|---|
| `brlaser` v6 | 全开源 CUPS filter `rastertobrlaser` + `brlaser.drv` | Brother 激光/LED 打印机（HL-1110/1210W/L2300D/L2340DW/L2360DN、DCP-1510/1600/7030/7055/7060D/7080/L2500D/L2520D/L2540DW、MFC-1910W 等约 29 个型号） |
| `brhl3040cnfilter` | Brother 官方 **i386 闭源** filter + LUT 色彩表（从 hl3040cnlpr-1.1.2-1.i386.deb 重打包） | 仅 Brother HL-3040CN |
| `brhl3040cncupswrapper` | 本 feed 重编译的 aarch64 CUPS filter + PPD | 仅 Brother HL-3040CN |

**安装后在 CUPS「添加打印机」里可见吗？可见（需本 feed 2024-10-30 之后的版本）：**

- `brlaser` 装完即把 `brlaser.drv` 装进 `/usr/share/cups/drv/`，CUPS 的 `lpinfo -m` / 添加打印机列表会直接列出全部 29 个型号（早期版本漏装 drv，只能 `lpadmin -P` 手动指定 PPD，已修复）；
- `brhl3040cncupswrapper` 装完会把 PPD 同时放到 `/usr/share/ppd/hl3040cn.ppd` 和 `/usr/share/cups/model/brother/hl3040cn.ppd.gz`，后者在 CUPS 添加打印机列表中显示为 "Brother HL3040CN"。

**HL-3040CN 的数据流与注意点：**

```
CUPS → brhl3040cncupswrapper(aarch64，写 /tmp/brparam.rc、/tmp/brpaper.inf)
     → exec /opt/brother/Printers/hl3040cn/brhl3040cnfilter(i386 闭源)
     → 打印机
```

- aarch64 上跑 i386 filter 依赖 `box86` + `libarmeabi`，**本 feed 已提供这两个包**（`box86` 为 armhf 32 位 + Dynarec，随包附带 armhf 与 i386 两套 glibc；`libarmeabi` 提供 `/lib/libc.so.6`、`/lib/libm.so.6` 垫片），apk 会自动带上依赖。
- 前提：内核必须开启 `CONFIG_COMPAT`（AArch32 兼容层）。验证：`/opt/brother/Printers/hl3040cn/brhl3040cnfilter` 能打印 `Error: invalid option !!` 即整链正常；若报 `Exec format error` 说明内核未开 32 位兼容。
- `box86 -v` 会打印两行 `sh: lscpu: not found`，这是 box86 探测 CPU 型号时调用 `lscpu` 产生的噪声，无害可忽略。
- 二选一即可：HL-3040CN 优先试 `brlaser`？不行——brlaser 不含 3040CN，这个型号只能走官方 filter 路线。

**通用建队命令（两包通吃）：**

```sh
apk add brlaser                       # 或 brhl3040cnfilter brhl3040cncupswrapper
lpinfo -m | grep -i brother                # 确认驱动已可见
lpadmin -p Brother -v usb:///dev/usb/lp0 -m everywhere && lpadmin -p Brother -E   # 或:
lpadmin -p HL3040CN -v usb:///dev/usb/lp0 -P /usr/share/ppd/hl3040cn.ppd -E
```

### 7.8 CUPS 网页管理：管理员账号、关掉强制 HTTPS、放开内网段

**为什么会跳到 https / 报 `Upgrade Required`（426）**

CUPS 2.2 起对 `<Location /admin>` 默认要求加密，浏览器用 `http://<IP>:631/admin` 会被重定向到 `https://<IP>:631/admin`，而 cupsd 用的是自签证书，于是继续报证书错误，管理页永远进不去。要两处同时成立才不跳：

1. `cupsd.conf` 顶层 `DefaultEncryption Never`
2. 各 `<Location>` 里不能有 `Encryption Required`（有就删掉或改成 `IfRequested`）

**"管理员"是谁：CUPS 没有自己的账号库**

它用**系统账号 + `SystemGroup`**（写在 `cups-files.conf`）判定：只有属于 `SystemGroup` 所列组的用户才能进 `/admin`。上游 Linux 默认是 `lpadmin` 组，**OpenWrt 没有这个组**，所以默认任何账号都进不去。

```sh
grep -n SystemGroup /etc/cups/cups-files.conf
grep -E '^(lpadmin|cupsadmin):' /etc/group
```

两种做法：

```sh
# 做法 A：直接用 root 登录（最省事）
# cups-files.conf 里改成：SystemGroup root
# 前提：root 已设密码（passwd root），且 cupsd 以 root 运行（能读 /etc/shadow，OpenWrt 默认如此）

# 做法 B：建专用管理员（推荐，不动 root）
addgroup -S cupsadmin
adduser  -S -D -H -G cupsadmin -s /bin/false cupsadmin
passwd cupsadmin
# cups-files.conf 里改成：SystemGroup sys root cupsadmin
```

**cupsd.conf 需要的块**（先 `cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak`）

```apache
Listen 0.0.0.0:631              # 原来若是 localhost:631，外网段根本连不上
Listen /var/run/cups/cups.sock  # 保留：本机 CLI 走 socket 免密码
WebInterface Yes                # 打开网页管理
DefaultAuthType Basic
DefaultEncryption Never         # ★ 关键：不再强制跳 https

<Location />
  Order allow,deny
  Allow 127.0.0.1
  Allow 192.168.0.0/16
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
</Location>

<Location /admin>
  AuthType Default
  Require user @SYSTEM          # 只有 SystemGroup 成员可进
  Order allow,deny
  Allow 127.0.0.1
  Allow 192.168.0.0/16
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
</Location>

<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow 127.0.0.1
  Allow 192.168.0.0/16
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
</Location>
```

上面三个网段覆盖了绝大多数家用/办公内网，**按实际 LAN 改成一条**（如 `Allow 192.168.1.0/24`）更严谨。`Allow @LOCAL` 也可以，但它只认"直连网段"，路由器桥接/容器场景经常判不出来，所以这里写死网段更可靠。

**生效与验证**

```sh
cupsd -t                       # 语法检查，必须先过
/etc/init.d/cupsd restart
grep -n Encryption /etc/cups/cupsd.conf   # 除 DefaultEncryption Never 外不应再有 Encryption 行
curl -sI http://127.0.0.1:631/admin | head -1
# 期望：HTTP/1.1 401 Unauthorized   （要求认证＝正常）
# 若是 426 Upgrade Required → 还有 Encryption Required 没清干净
```

浏览器访问 `http://<路由器IP>:631/admin`，弹出认证框时输入 `cupsadmin`（做法 B）或 `root`（做法 A）＋密码，即可进入 Administration。

**注意点**

- `DefaultEncryption Never` + Basic 认证 = 密码以 base64 明文过网，**只在内网用**，绝不要把 631 映射到 WAN；防火墙默认也不放行 WAN→631，不需要额外动作。
- 本机 root 跑 `lpadmin` / `hp-setup` 走 `/var/run/cups/cups.sock`，由 socket 对端身份自动认证，**完全不需要网页登录**——建队列这条主线可以完全不碰 web 管理。
- 若登录一直失败，先确认 cupsd 是否带 PAM：`strings /usr/sbin/cupsd | grep -c pam_`。命中但 `/etc/pam.d/cupsd` 不存在时，认证会始终失败；此时退回"只用 CLI 管理"，或改用 `SystemGroup root`（无 PAM 时 CUPS 直接读 `/etc/shadow` 比对）。
- 给客户端共享打印机（IPP）：`lpadmin` 建好队列后，其他机器用 `ipp://<路由器IP>:631/printers/<队列名>` 添加即可，不需要开 `Browsing`。

### 7.9 CUPS Web 界面中文化

Web 管理界面（`http://<路由器IP>:631`）的页面由 `/usr/share/cups/templates/*.tmpl` 渲染，CGI 直接读文件，**覆盖即生效**，与浏览器 `Accept-Language`、`DefaultLanguage` 都无关。首页 `/` 则是静态文件 `doc-root/index.html`，与模板是两套东西，缺一个就会出现「首页叫类别、内页叫类」这类不一致。

本仓库 `cups-zh/` 目录是这套中文界面包（含 `cups-zh-cn.tar.gz` 成品包）：

| 内容 | 说明 |
|---|---|
| `cups-zh-cn.tar.gz` | 20 KB，65 个中文模板 + 中文首页 + `install.sh` |
| `templates/` | 同上，未打包的源文件，便于对比与二次修改 |
| `doc-root/index.html` | 中文首页 |
| `install.sh` | 安装 / `--restore` 还原英文 |
| `README.md` | 译文来源、逐项修补清单、已知限制 |

安装：

```sh
# 把 cups-zh-cn.tar.gz 传到路由器
cd /tmp && tar xzf cups-zh-cn.tar.gz && cd cups-zh-cn && sh install.sh
# 装完 Ctrl+F5 强刷，浏览器会缓存模板渲染结果
sh install.sh --restore        # 想回英文
```

脚本会自动做完这些事（不需要手动指定路径）：

1. 探测 `DocumentRoot`：先看 `cups-files.conf` 里未注释的 `DocumentRoot`，没有就按 `cups.css` 实际位置反推。**OpenWrt 的 cups 把 doc-root 装在 `/usr/share/doc/cups`**，而 `/usr/share/cups/` 下根本没有 `doc-root`，写死路径必然扑空。
2. 英文原件备份到 `/usr/share/cups/templates/default.en/`，首页备份为 `index.html.en`。
3. 按本机 `header.tmpl` 判断用 `.header` 还是 `.cups-header` 类名——CUPS 2.4 系列中途改过类名，用错会让导航栏丢样式。
4. 只覆盖本机真实存在的模板（上游已删的旧模板自动跳过），装完列出「本机有、包里没有」的英文模板。
5. 重启 `cupsd`。

相对上游译文做的修补（详见 `cups-zh/README.md`）：

- `printer-added.tmpl` 补回「设置打印机选项」表单（`org.cups.sid` 全缺，否则加完打印机没有下一步入口）；
- `jobs.tmpl` 补回 `{job_hold_until=auth-info-required?}` 分支，译全 `pending since / completed at / Unknown / Withheld`；
- 导航「类别」「类」统一为**集群**，删掉「帮助」（`/help/` 文档未随固件打包，点了必 404）；class 相关 10 个模板的「添加类/删除类/修改类」同步改为集群；
- 首页正文原来整片是 `help/*.html` 死链，换成「常用入口」+「使用提示」两栏。

已知限制：`apk add -u cups` 会覆盖模板，升级后需重跑一次 `install.sh`；`help/` 在线帮助文档未汉化（原始译文包也没做完，几 MB 放路由器 Flash 不划算）。

### 7.10 无真机的链路自测（tools/）

`tools/` 下四个脚本各验一条驱动链，**不需要插打印机**：

| 脚本 | 链路 | 设备流判据 |
|---|---|---|
| `test-hplip-1020.sh` | PS → raster → hpcups | `ESC E` + UEL + `@PJL ENTER LANGUAGE=ZJS` + `JZJZ` |
| `test-foo2zjs-1020.sh` | PS → foo2zjs-wrapper → foo2zjs | `@PJL JOB` + `JZJZ` + `@PJL EOJ`（**无** ENTER LANGUAGE） |
| `test-brlaser-hl2140.sh` | PS → raster → rastertobrlaser | `@PJL JOB` → `@PJL ENTER LANGUAGE = PCL` → `ESC E` → `@PJL EOJ` |
| `test-splix-ml2010.sh` | PS → raster → rastertoqpdl | 头 `ESC%-12345X`、尾 `TAB+ESC%-12345X`、中间 QPDL 记录 |

同目录还有 `foo2zjs-fw-setup.sh`（固件下发与 hotplug 互斥，见 7.6.1）和两个定位脚本 `diag-raster.sh` / `probe-gstoraster.sh`。

```sh
scp tools/*.sh root@<路由器>:/tmp/
sh /tmp/test-hplip-1020.sh --full      # --full 追加 cupsd 全链路（假 backend 落盘）
sh /tmp/diag-raster.sh                 # 段1 报错时先跑这个，专查 PS 为什么转不出 raster
sh /tmp/probe-gstoraster.sh --cups     # 怀疑 gstoraster 崩（rc=139）时跑这个，看作业是否被判失败
```

两个曾把结论带偏的坑，脚本已按下面的方式绕开：

1. **`cupsfilter -p <ppd>` 在本机 CUPS 2.4 上会停在 PS→PDF。** stderr 会抛 `ppdFilterLoadPPD: Last filter could not get determined`，产物以 `%PDF-1.3` 开头，`gs -sDEVICE=pdfwrite` 的 `%%Invocation` 就写在文件头里。此时后面所有「缺 UEL / 缺 JZJZ」的 FAIL 全是假警报。脚本改为按 cupsd 的真实做法**拆两段**：先 `cupsfilter -m application/vnd.cups-raster`（失败退回直接调 `gstoraster`）拿 CUPS raster，再带 `PPD=` / `DEVICE_URI=` 直接调驱动过滤器（`hpcups` / `rastertobrlaser` / `rastertoqpdl`），参数顺序与 cupsd 一致（`job-id user title copies options file`）。
2. **假 backend 的输出文件名曾经对不上。** CUPS 传给 backend 的第一个参数是 job-id（如 `11`），不是队列名，旧脚本却去等 `/tmp/savefile-<队列名>.prn`，于是「作业已完成、文件找不到」。现在队列 URI 直接写成 `savefile:/tmp/<tag>/job.prn`，backend 从 `DEVICE_URI` 取路径，落盘位置确定；新建 backend 后向 cupsd 发 `SIGHUP` 让它重扫 backend 目录。

另外两点判读经验：**纯色页体积最小是正常的**（ZJS/QPDL 都是差分编码），验证「编码器真的在按像素干活」必须用噪点页；`cupsfilter` 选错层时四张页的体积会一模一样（都是同一份 PDF），这本身就是「没走到编码器」的信号。

**段1（PS → CUPS raster）失败意味着什么。** hpcups / rastertobrlaser / rastertoqpdl 吃的都是 CUPS raster，这一步由 cups-filters 的 `gstoraster` 完成，`gstoraster` 内部再调 `gs -sDEVICE=cups`。所以只要 gs 的 `cups` 设备不可用，**三个 raster 驱动会同时全哑**，而 foo2zjs 照常工作（它自己调 gs 出 pbmraw）——这是两条链最容易分道扬镳的地方。脚本为此准备了三级退路并打印实际走的是哪条：

| 退路 | 命令 | 说明 |
|---|---|---|
| 1 | `cupsfilter -p ppd -m application/vnd.cups-raster` | 走 cups-filters 的正规链 |
| 2 | `gstoraster 1 root t 1 "PageSize=A4" x.ps` | cupsfilter 内部那一步 |
| 3 | `gs -sDEVICE=cups -r600 -g4960x7016 -dcupsBitsPerColor=1 -dcupsColorSpace=3` | 绕开 cups-filters 直接调 gs |

三级都失败时先跑 `diag-raster.sh`：它分别验 gs 的 cups 设备、`gstoraster`、`cupsfilter -m`，再把拿到的 raster 喂给三个编码器。

### 7.11 实战排查记录：五个把结论带反的坑（2026-11）

真机（aarch64 OpenWrt，gs 10.08.0，CUPS 2.4.20，cups-filters 2.0.1）上按这套脚本跑，先后踩到五个坑，全都已固化进脚本。它们的共同点是：**报出来的 FAIL 看着像驱动坏了，其实都在脚本自己身上**——真正坏的东西一次都没出现。

**坑一：CUPS raster 的同步字是 `3SaR`，不是 `RaS3`。** 这是最要命的一个——`cups/raster.h` 里 `CUPS_RASTER_SYNC = 0x52615333`（"RaS3"），但文件是按主机字节序写的，**小端机上落盘就是 `33 53 61 52`，即 `3SaR`**。脚本原来只判 `RaS*`，于是所有合法的 raster 都被判成「没出 raster」，段1 永远 FAIL。现在 `is_raster()` 两种字节序都认：

```sh
case "$(first4 f.raster)" in RaS3|3SaR) ... ;; esac
```

**坑二：`gstoraster` 退出码 139（SIGSEGV），但它不是 cupsd 用的那个入口。** 本机的 `gstoraster` 在 `Rendering completed`、`gs exited with no errors` 之后仍然段错误退出，产物本身合法（3941714 字节、`3SaR` 开头、页数对）——崩在退出清理，不在渲染。

关键一点：cups-filters 2.0.1 的 `gstoraster` / `pdftoraster` / `universal` / `pstopdf` 等是**同一个多呼叫二进制的不同入口**（所以文件大小几乎一致）。cupsd 实际调用的是 `universal` 入口，它没有这个毛病：

```
[Job 26] PID 7734 (/usr/lib/cups/filter/universal) exited with no errors.
[Job 26] Job completed.
```

`cupsfilter -m` 也走 `universal`，所以它 rc=0，而手工调 `gstoraster` 是 139。结论：**139 只影响这个旧入口，不影响真机打印**；但手工验证要么用 `cupsfilter -m`，要么按 cupsd 的方式用管道，并用子 shell 取真实退出码：

```sh
( PPD=x gstoraster ... 2> err; echo $? > rc ) | cat > out.raster
```

`probe-gstoraster.sh` 专测这一点（三种调用方式 + `pdftoraster` 对照 + `--cups` 真跑一页）：

```sh
sh /tmp/probe-gstoraster.sh           # 只测过滤器：文件 / 管道 / /dev/null
sh /tmp/probe-gstoraster.sh --cups    # 再用 cupsd + 假 backend 真打一页
```

**坑三：`lpinfo -v` 列的是「设备」，不是 backend 清单。** 自建的假 backend 无参数调用时直接 `exit 0`（不报设备），所以它永远不会出现在 `lpinfo -v` 里。旧脚本据此判定「cupsd 没扫到 savefile」，结论是错的。正确的证据链是：`error_log` 里出现 `Started backend /usr/lib/cups/backend/savefile` + `lpstat -v <队列>` 里记着 `savefile:/...`。

**坑四：假 backend 是普通用户跑的，写不进 root 建的目录。** 这一条让四份脚本的第 6 步（cupsd 全链路）全部 FAIL，而段1/段2 早已全绿——现象长这样：

```
[Job 23] /usr/lib/cups/backend/savefile: line 4: can't create /tmp/savefile.log: Permission denied
[Job 23] /usr/lib/cups/backend/savefile: line 9: can't create /tmp/hplip1020/job.prn: Permission denied
[Job 23] PID 7182 (/usr/lib/cups/backend/savefile) exited with no errors.
```

cupsd 以 `lp`（OpenWrt）/ `cups`（发行版）身份执行 backend，`/tmp/<tag>` 是 root 建的 755，进不去；日志写 `/tmp/savefile.log` 也会撞上 root 的 644。连带后果很容易误判：backend 立刻退出 → 上游管道断裂 → `rastertoqpdl` 报 `did not catch or ignore signal 13`（SIGPIPE）、`brlaser: Could not write print data`，看起来像驱动 bug，其实是权限。现在的做法：`chmod 777 $TMP`、日志写在输出文件旁边（`$OUT.log`，backend 自己创建）、backend 里记下 `user=$(id -un)`，失败时先看这一行是谁。

**坑五：固件转换吐 0 字节，其实是转换器选错了；同一份输出里还藏着「插的是另一台机器」。** 真实的体检输出长这样：

```
---- 候选：/usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz（70412 字节）
---- 不行：arm2hpdl /usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz 只出了 0 字节
---- 不行：zcat ... | arm2hpdl 只出了 0 字节
[FAIL] arm2hpdl 两种输入方式都失败 —— 这份 .fw 可能不是它认识的封装
---- 现场其它 HP 设备：/sys/bus/usb/devices/1-1  03f0:3217
```

两个问题叠在一起：

1. **`.fw.gz` 不该给 `arm2hpdl`**。它只认 HP 官方 `.img`（内部 `FW` 头），喂 hplip 的封装必然 0 字节。`.fw.gz` 是 gzip 压缩的裸 `.dl`，`zcat` 出来直接就是成品（见 7.6.1）。文件从没坏过。
2. **`03f0:3217` 是 LaserJet 3050，不是 1020（`2b17`）**。3050 是 PCL5 完整机型，固件在机器里，压根不需要灌 `.dl` —— 对着它跑这套脚本，每一步都会"顺利"地什么都不发生，而 `[FAIL]` 会把人往"固件坏了"的方向带。型号对照：`2b17`=1020/1020plus、`3217`=3050、`4117`=1018、`3d17`=P1005、`3e17`=P1006。

脚本现在两处都改了：第 0 步按 PID 报出机型名并提示「上面若没有 2b17，就别往下灌固件，灌错固件会让设备挂死」；第 2 步优先 `zcat` 直通，`arm2hpdl` 退为第二条路。另外 `usblp` 未加载时不再只打一行 `----`，而是明确给出 `apk add kmod-usb-printer`，并注明 libusb 通道（`--hplip`）不受影响。

同一台机上的实测数据，可作判读基准（左列均为脚本原样输出）：

| 检查项 | 实测值 | 判读 |
|---|---|---|
| `gs --version` / `gs -h` | 10.08.0，含 `cups`/`pwgraster`/`pbmraw` | gs 设备齐全，不是 gs 的问题 |
| 段1 `cupsfilter -m` | 3941131 字节，头 `3SaR`，rc=0 | raster 层正常 |
| `gstoraster` 直调 | 3941714 字节，rc=**139** | 崩在退出清理，cupsd 不走这个入口 |
| `cupsfilter -m` / `pdftoraster` | 均 rc=0 | 与 cupsd 一致的那几条路都好 |
| hplip 段2 | 3559 字节，含 `ESC E` + `UEL` + `@PJL ENTER LANGUAGE=ZJS` + `JZJZ` | 编码器可用（012 补丁无影响） |
| brlaser 段2 | 20269 字节，`@PJL JOB` → `ENTER LANGUAGE = PCL` → `ESC E` → `@PJL EOJ` | 编码器可用 |
| splix 段2 | 12507 字节，首 `ESC%-12345X`、尾 `TAB+ESC%-12345X` | 编码器可用（QPDL 记录齐全） |
| 内容相关性（空白/噪点） | hplip 487/8231、brlaser 7856/31673、splix 337/311442 | 三条链都在按像素做差分编码 |
| cupsd 实际跑的过滤器 | `universal` + 驱动过滤器 | 与手工 `gstoraster` 不是同一入口 |

顺带一个打包 bug：`/usr/lib/cups/filter/command2foo2lava-pjl` 是指向 `/home/opc/openwrt/build_dir/...` 的**绝对软链**，装到路由器上必然悬空（它属于 lava 分支，不影响 1020，但说明 foo2zjs 的 install 段有漏改）。修法是打包时用相对软链或直接装实体文件。

## 八、OpenWrt 25（master）迁移：GCC 14 + Python 3.14 修复

24.10 用的是 GCC 13.3 / Python 3.11，master 快照已经是 **GCC 14.4 / Python 3.14**。GCC 14 把一批原本只是 warning 的问题升级成了 error（`-Werror=implicit-function-declaration`、`-Werror=implicit-int`、`-Werror=incompatible-pointer-types`、`-Werror=return-mismatch`），hplip 3.25.6 因此连续炸了 7 轮。全部修复落在 `hplip/` 内，`PKG_RELEASE` 3 → 10。

| # | 位置 | 现象 | 根因 | 修法 |
|---|---|---|---|---|
| 1 | host 阶段（python-distro） | `Backend 'setuptools.build_meta' is not available` | hostpkg 的 Python 3.14 环境没装 setuptools，PEP 517 构建后端缺失 | `staging_dir/hostpkg/bin/python3 -m pip install setuptools` |
| 2 | `common/utils.c` | `strcasestr` 隐式声明 | musl 只在 `_GNU_SOURCE` 下声明 `strcasestr` | Makefile 加 `TARGET_CFLAGS += -D_GNU_SOURCE` |
| 3 | `prnt/hpps/pserror.c:27` | `static column = 0` 报 implicit-int | K&R 风格漏写类型 | 补 `int`（patch 014） |
| 4 | `prnt/cupsext/cupsext.c` | 调用 `_releaseCupsInstance` / `addCupsPrinter` 等 5 个函数无原型 | 原型在 `protocol/hp_ipp.h` 里缺声明 | 补声明（patch 015） |
| 5 | `scan/sane/hpaio.c` | `orblite_*` 未声明；void 函数 `return orblite_close()` 返回值不匹配 | 只 include 了 `orblitei.h`（内部头），公开头是 `orblite.h` | 加 `#include "orblite.h"`，改为先调用再 `return;`（patch 016） |
| 6 | `scan/sane/hpaio.c` | `SANE_Device***` 传参 incompatible-pointer-types | `orblite_get_devices()` 签名是 `const SANE_Device **` | 改 `const SANE_Device **devList = NULL; orblite_get_devices(&devList, ...)`（patch 017） |
| 7 | `scan/sane/bb_ledm.c`、`http.c` | `usleep` 隐式声明 | 缺 `<unistd.h>` | 补 include（patch 018） |
| 8 | `scan/sane/sclpml.c` / `orblite.c` / `pcard/pcardext/pcardext.c` | `gettimeofday` 未声明；9 处 `(SANE_Char**)` 常量性错误；`_DBG` 未定义；`PyString_*` / `Py_InitModule4` 不存在 | 缺 `<sys/time.h>`、`<dlfcn.h>`；pcardext 仍是 Python 2 C API | 补头文件、`(const SANE_Char**)`、`_DBG` 换 `syslog(LOG_DEBUG,…)`、pcardext 移植到 Python 3（`PyBytes_*` / `PyLong_AsLong` / `PyModule_Create` + `PyInit_pcardext`）（patch 019） |

### 8.1 方法论：先用 `-fpermissive` 打一发「全量告警」

逐个报错逐个修，一轮编译 5 分钟，7 个错就是 35 分钟纯等待。有效做法是先临时加 `-fpermissive`（或 `TARGET_CFLAGS += -Wno-error=implicit-function-declaration ...`）跑一次**全量**编译，把 GCC 14 提升为 error 的点一次性全部暴露出来（warning 里逐条可见），再统一打补丁、撤掉宽松参数严格重编。一次拿到 9 处残留，比迭代快一个数量级。

### 8.2 三个容易踩回去的点

1. **`TARGET_CFLAGS += -D_GNU_SOURCE` 必须保留**，不是临时调试参数——musl 下没有它 `strcasestr` 就不存在，删了立刻回到隐式声明错误。
2. **`orblite.c` 是 CRLF 文件**。用脚本改它生成补丁时必须按 bytes 读写，否则整个文件的行尾被统一，diff 会变成全文替换，补丁无法 review。
3. **`pcardext.c` 的 Python 2 → 3 移植要注意模块名**：`PyModule_Create` 之后初始化函数必须叫 `PyInit_pcardext`，并且 `PyModuleDef` 的 `m_name` 要和 setup.py 里的扩展名一致，否则运行期 import 才报错（编译期看不出来）。

### 8.3 与上游的关系

`feeds/packages/utils/hplip`（同为 3.25.6）带有 `040-gcc14.patch`，处理的是同一批问题，修法可交叉验证；另有 `060-gcc15.patch` 供将来 GCC 15 使用。本仓库把修复拆成 014~019 六个独立补丁，便于按问题单独回溯。

box86 0.3.9 armhf build (for AArch64 OpenWrt with CONFIG_COMPAT kernel)
- /opt/armhf/bin/box86   : box86 ELF32 ARM (EABI5, hard-float), interpreter patched to /opt/armhf/lib/ld-linux-armhf.so.3
- /opt/armhf/lib/        : bundled armhf glibc 2.35 runtime (Ubuntu 22.04 cross toolchain)
- /usr/bin/box86         : wrapper script
Built from https://github.com/ptitSeb/box86 commit bb716a2a

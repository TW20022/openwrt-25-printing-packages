#
# Box86 prebuilt armhf package for aarch64 OpenWrt
#

include $(TOPDIR)/rules.mk

PKG_NAME:=box86
PKG_VERSION:=0.3.9
PKG_RELEASE:=3

RSTRIP:=true

include $(INCLUDE_DIR)/package.mk

define Package/box86
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Printing
  DEPENDS:=+libc @aarch64
  TITLE:=Box86 x86 emulator (armhf, bundled glibc, needs CONFIG_COMPAT kernel)
  URL:=https://github.com/ptitSeb/box86
endef

define Package/box86/description
  Box86 runs i386 Linux programs on ARM devices. This is an armhf build
  running under the AArch32 compat layer, with a bundled armhf glibc in
  /opt/armhf so it works on musl-based OpenWrt.
  Requires kernel CONFIG_COMPAT=y.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/box86/install
	$(CP) ./files/* $(1)/
	chmod 755 $(1)/opt/armhf/bin/box86 $(1)/usr/bin/box86
endef

$(eval $(call BuildPackage,box86))

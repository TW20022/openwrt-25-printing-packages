#
# Copyright (C) 2026
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libarmeabi
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/libarmeabi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Printing
  DEPENDS:=+libc
  TITLE:=ARM ABI compat shim (libc.so.6/libm.so.6 -> musl)
  URL:=https://github.com/
endef

define Package/libarmeabi/description
  Provides glibc-style /lib/libc.so.6 and /lib/libm.so.6 symlinks
  pointing to musl libc, used by box86 when running legacy i386
  binaries (e.g. Brother HL-3040CN closed filter).
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/libarmeabi/install
	$(INSTALL_DIR) $(1)/lib
	ln -sf libc.so $(1)/lib/libc.so.6
	ln -sf libc.so $(1)/lib/libm.so.6
	$(INSTALL_DIR) $(1)/usr/lib
endef

$(eval $(call BuildPackage,libarmeabi))

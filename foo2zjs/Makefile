#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=foo2zjs
PKG_VERSION:=20260206
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OpenPrinting/foo2zjs/archive/refs/tags/
PKG_HASH:=5f95fd47de9001d750d534ec7c729b2157734b483cb7400081b0d6973f92dcd0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PATCH_DIR:=./patches

include $(INCLUDE_DIR)/package.mk

define Package/foo2zjs
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A linux printer driver for QPDL protocol
	URL:=https://github.com/koenkooi/foo2zjs
	DEPENDS:=+ghostscript +cups +libjbigkit +cups-filters
endef

define Package/foo2zjs/description
	foo2zjs is a linux printer driver for QPDL protocol and other related printer streams.
	It converts pbm (B/W) images and cmyk images to printer-specific formats.
endef

define Build/Prepare
	# 1. 确保构建目录存在
	mkdir -p $(PKG_BUILD_DIR)
	
	# 2. 如果 dl 目录中没有该压缩包，则使用 curl 手动下载并重命名保存
	@if [ ! -f $(DL_DIR)/$(PKG_SOURCE) ]; then \
		echo "Downloading foo2zjs source..." ; \
		curl -fL -o $(DL_DIR)/$(PKG_SOURCE) \
			--connect-timeout 20 --retry 5 \
			https://github.com/OpenPrinting/foo2zjs/archive/refs/tags/20260206.tar.gz || \
		( echo "Download failed"; rm -f $(DL_DIR)/$(PKG_SOURCE); exit 1 ); \
	fi

	# 3. 使用 tar 解压到构建目录并剥离外层版本目录
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1

	# 4. 应用 patches 目录下的所有补丁文件
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR))
endef

define Build/Compile
	# 1. 显式交叉编译根目录下的主程序和工具
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		all

	# 2. 交叉编译 icc2ps 子目录
	$(MAKE) -C $(PKG_BUILD_DIR)/icc2ps \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		all
endef

define Package/foo2zjs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/cups/model
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/foo2zjs

	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(1) install-prog
	$(MAKE) -C $(PKG_BUILD_DIR)/icc2ps DESTDIR=$(1) install
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(1) install-crd
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(1) install-foo
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(1) install-ppd
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(1) install-filter
endef

define Package/foo2zjs/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/cupsd enabled && {
		/etc/init.d/cupsd restart
	}
}
endef

$(eval $(call BuildPackage,foo2zjs))

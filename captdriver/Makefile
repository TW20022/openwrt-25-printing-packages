#
# Copyright (C) 2026 WorkBuddy
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=captdriver
PKG_VERSION:=0.1.4.1
PKG_RELEASE:=1

PKG_SOURCE:=master.tar.gz
PKG_SOURCE_URL:=https://ghproxy.net/https://github.com/cryptoluks/captdriver/archive/refs/heads/
PKG_HASH:=d7a316e82a93b82ffb66815d170a1627c0c89f92c2437fe2abe4e9808d70b578

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=README.md

include $(INCLUDE_DIR)/package.mk

define Package/captdriver
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Printing
	TITLE:=Open-source CUPS CAPT driver (Canon LBP2900/LBP3000)
	URL:=https://github.com/cryptoluks/captdriver
	DEPENDS:=+libcups +cups
endef

define Package/captdriver/description
	captdriver is a GPLv3 CUPS raster filter for Canon CAPT laser printers.
	It talks the CAPT protocol directly over the CUPS USB backend, so no
	Canon proprietary ccpd daemon and no x86/32-bit runtime libraries are
	needed. Works on aarch64/musl. Supported: LBP2900 (works),
	LBP3000 (experimental), LBP3010/3018/3050, LBP3100/3108/3150,
	LBP6000/6018.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

CAPTDRIVER_SRCS := rastertocapt.c capt-command.c capt-status.c \
	generic-ops.c printer.c paper.c hiscoa-common.c \
	hiscoa-compress.c prn_lbp2900.c

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -std=c99 -Wall \
		-I$(PKG_BUILD_DIR)/src \
		-I$(STAGING_DIR)/usr/include/cups \
		-o $(PKG_BUILD_DIR)/rastertocapt \
		$(addprefix $(PKG_BUILD_DIR)/src/,$(CAPTDRIVER_SRCS)) \
		-L$(STAGING_DIR)/usr/lib -lcups -lm $(TARGET_LDFLAGS)
endef

define Package/captdriver/install
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rastertocapt $(1)/usr/lib/cups/filter/rastertocapt
	$(INSTALL_DIR) $(1)/usr/share/cups/model
	$(INSTALL_DATA) ./files/CanonLBP-2900-3000.ppd $(1)/usr/share/cups/model/CanonLBP-2900-3000.ppd
endef

define Package/captdriver/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/cupsd enabled && /etc/init.d/cupsd restart
}
endef

$(eval $(call BuildPackage,captdriver))

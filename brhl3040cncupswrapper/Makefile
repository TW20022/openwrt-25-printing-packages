#
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=brhl3040cncupswrapper
PKG_VERSION=1.0
PKG_RELEASE=2

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Printing
	DEPENDS:=+libcupsimage +brhl3040cnfilter +libc +box86 +libarmeabi
	TITLE:=$(PKG_NAME)
	URL:=https://github.com/
endef

define Package/$(PKG_NAME)/description
	$(PKG_NAME)
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99 -fPIC -fvisibility=hidden -fno-exceptions -ffunction-sections -fdata-sections -Wall -Werror -Wno-unused-variable -Wno-unused-but-set-variable -Wno-deprecated-declarations -DPACKAGE=\\\"brhl3040cncupswrapper\\\" -DVERSION=\\\"1.0\\\"" \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,--gc-sections -lcupsimage -lcups"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/ppd
	$(INSTALL_DATA) ./files/hl3040cn.ppd $(1)/usr/share/ppd/
	$(INSTALL_DIR) $(1)/usr/share/cups/model/brother
	gzip -9 -c ./files/hl3040cn.ppd > $(1)/usr/share/cups/model/brother/hl3040cn.ppd.gz
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

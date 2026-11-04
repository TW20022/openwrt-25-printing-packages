include $(TOPDIR)/rules.mk

PKG_NAME:=brlaser
PKG_VERSION:=6
PKG_RELEASE:=1

PKG_SOURCE:=v6.tar.gz
PKG_SOURCE_URL:=https://github.com/pdewacht/brlaser/archive/refs/tags
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/brlaser-6

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/brlaser
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Printing
	TITLE:=Brother laser printer driver
	URL:=https://github.com/pdewacht/brlaser
	DEPENDS:=+libcups +libcupsimage +libstdcpp
endef

define Package/brlaser/description
	Brother laser printer driver
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF

define Package/brlaser/install
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/lib/cups/filter/rastertobrlaser \
		$(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/cups/drv
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/cups/drv/brlaser.drv $(1)/usr/share/cups/drv/
endef

$(eval $(call BuildPackage,brlaser))

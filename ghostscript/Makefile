include $(TOPDIR)/rules.mk

PKG_NAME:=ghostscript
PKG_VERSION:=10.08.0
PKG_VERSION_LIBDIR:=10.08.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10080
PKG_HASH:=caf199e3f233f1290b27d0972d636f66c303355f2353309b7bfddf1edda06b3d
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=cups

include $(INCLUDE_DIR)/package.mk

# === 兼容 GCC 13 与 GCC 14 的关键位置 ===
# 使用 EXTRA_LDFLAGS 确保链接参数追加到命令的最后面，解决新版 GCC 严格的符号检查问题
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib
EXTRA_LDFLAGS += -lcups -lcupsimage

define Package/ghostscript
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ghostscript
  DEPENDS:=+cups +libcups +libcupsimage +fontconfig +libtiff \
	+libjpeg-turbo +libpng +libexpat +zlib
  SUBMENU:=Printing
endef

define Package/ghostscript/description
	Ghostscript, an interpreter for the PostScript language and for PDF.
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR) && $(RM) -r expat jpeg libpng tiff zlib)
	$(call Build/Configure/Default, \
		--disable-gtk	\
		--without-libidn \
		--without-x \
		--with-jbig2dec=yes \
		--enable-cups \
		--with-system-libtiff \
		--with-cups-serverbin="/usr/lib/cups" \
		--with-cups-serverroot="/etc/cups" \
		--with-cups-datadir="/usr/share/cups" \
		CUPSCONFIG="$(STAGING_DIR)/usr/bin/cups-config" \
	)
endef

define Package/ghostscript/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/doc/ghostscript
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/ghostscript/* $(1)/usr/share/doc/ghostscript/
	$(INSTALL_DIR) $(1)/usr/share/ghostscript
	$(CP) $(PKG_INSTALL_DIR)/usr/share/ghostscript/* $(1)/usr/share/ghostscript/
endef

$(eval $(call BuildPackage,ghostscript))

#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gutenprint
PKG_VERSION:=5.3.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/gimp-print/gutenprint-5.3/$(PKG_VERSION)
PKG_HASH:=f5a9f47de28530b1ae2069cfbc647a9a641baeeabe809bb0ef2b3ec5b9668d70

PKG_BUILD_DEPENDS:=gutenprint/host cups
PKG_INSTALL:=1
PKG_FIXUP=autoreconf

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gutenprint-cups
  SECTION:=net
  CATEGORY:=Network
  TITLE:=gutenprint-cups -- Gutenprint CUPS drivers
  # XXX FIXME perl is required by cups-genppdupdate, but it needs more libs
  DEPENDS:=+cups +libcupsimage
  URL:=http://gimp-print.sourceforge.net/
  SUBMENU:=Printing
endef

# define Package/gutenprint-foomatic
#   SECTION:=net
#   CATEGORY:=Network
#   TITLE:=gutenprint-foomatic -- Gutenprint Foomatic drivers
#   # perl is required by cups-genppdupdate
#   DEPENDS:=+ghostscript +libiconv
#   URL:=http://gimp-print.sourceforge.net/
#   SUBMENU:=Printing
# endef

define Package/gutenprint-cups/description
	Gutenprint CUPS drivers for a wide range of Canon, Epson, HP and
	compatible printers.
endef

CONFIGURE_ARGS+= \
	--disable-nls \
	--disable-test \
	--without-doc \
	--without-readline \
	--without-foomatic \
	--without-foomatic3 \
	--enable-escputil=no \
	--disable-translated-cups-ppds \
	--disable-globalized-cups-ppds \
	--disable-simplified-cups-ppds \
	--bindir=/usr/bin \
	--sbindir=/usr/bin \
	--prefix=/usr \
	--exec-prefix=/usr

# Patch the Makefiles to run the binary from host compile
define Build/Compile
	# [fix-gutenprint-20261030b] host tool extract-strings lives in HOST_BUILD_DIR, which is wiped right after host install -> absolute path is always dangling. xmli18n-tmp.h is only consumed by po/POTFILES.in at dist time and never compiled (configure uses --disable-nls), so neutralize the rule instead of calling it.
	$(SED) "s#\.\(/extract-strings\)#true#" $(PKG_BUILD_DIR)/src/xml/Makefile
# [fix-gutenprint-20261030] 	$(SED) "s#\.\(/check_duplicate_printers.test\)#$(HOST_BUILD_DIR)/src/xml/printers\1#" $(PKG_BUILD_DIR)/src/xml/printers/Makefile
	$(call Build/Compile/Default)
endef

define Package/gutenprint-cups/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/bin
	# XXX Do not install cups-genppdupdate, as it requires Perl + some perl libs
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cups-genppd.[0-9]*.[0-9]* $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cups-calibrate $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/cups/driver $(1)/usr/lib/cups/filter
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/driver/gutenprint.* $(1)/usr/lib/cups/driver
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/* $(1)/usr/lib/cups/filter
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libgutenprint.* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/share/cups/mime
	$(CP) $(PKG_INSTALL_DIR)/etc/cups/command.types $(1)/usr/share/cups/mime
	$(INSTALL_DIR) $(1)/usr/share/gutenprint
	$(CP) $(PKG_INSTALL_DIR)/usr/share/gutenprint/[0-9]*.[0-9]* $(1)/usr/share/gutenprint
endef

define Host/Compile
	$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR)/src/xml $(HOST_MAKE_FLAGS) extract-strings
	$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR)/src/xml/printers $(HOST_MAKE_FLAGS) check_duplicate_printers.test
endef

define Host/Install
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,gutenprint-cups))

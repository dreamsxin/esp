#
#   esp-freebsd-default.mk -- Makefile to build Embedthis ESP for freebsd
#

NAME                  := esp
VERSION               := 1.0.0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= freebsd
CC                    ?= gcc
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_APPWEB         ?= 1
ME_COM_CGI            ?= 0
ME_COM_DIR            ?= 0
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MDB            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_NANOSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

ME_COM_COMPILER_PATH  ?= gcc
ME_COM_LIB_PATH       ?= ar
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(CONFIG)/inc"
LDFLAGS               += 
LIBPATHS              += -L$(CONFIG)/bin
LIBS                  += -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += $(CONFIG)/esp
TARGETS               += $(CONFIG)/bin/esp.conf
TARGETS               += $(CONFIG)/bin/esp
TARGETS               += $(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.so
endif
TARGETS               += $(CONFIG)/bin/libmprssl.so
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/sqlite
endif

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/esp-freebsd-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/esp-freebsd-default-me.h >/dev/null ; then\
		cp projects/esp-freebsd-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/obj/appwebLib.o"
	rm -f "$(CONFIG)/obj/edi.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/espAbbrev.o"
	rm -f "$(CONFIG)/obj/espFramework.o"
	rm -f "$(CONFIG)/obj/espHandler.o"
	rm -f "$(CONFIG)/obj/espHtml.o"
	rm -f "$(CONFIG)/obj/espTemplate.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/mdb.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/sdb.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libappweb.so"
	rm -f "$(CONFIG)/bin/libest.so"
	rm -f "$(CONFIG)/bin/libhttp.so"
	rm -f "$(CONFIG)/bin/libmod_esp.so"
	rm -f "$(CONFIG)/bin/libmpr.so"
	rm -f "$(CONFIG)/bin/libmprssl.so"
	rm -f "$(CONFIG)/bin/libpcre.so"
	rm -f "$(CONFIG)/bin/libsql.so"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/sqlite"

clobber: clean
	rm -fr ./$(CONFIG)


#
#   esp-paks
#
DEPS_1 += src/paks/appweb
DEPS_1 += src/paks/appweb/appweb.h
DEPS_1 += src/paks/appweb/appweb.me
DEPS_1 += src/paks/appweb/appwebLib.c
DEPS_1 += src/paks/appweb/LICENSE.md
DEPS_1 += src/paks/appweb/package.json
DEPS_1 += src/paks/appweb/README.md
DEPS_1 += src/paks/esp-html-mvc
DEPS_1 += src/paks/esp-html-mvc/LICENSE.md
DEPS_1 += src/paks/esp-html-mvc/package.json
DEPS_1 += src/paks/esp-html-mvc/README.md
DEPS_1 += src/paks/esp-html-mvc/templates
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/appweb.conf
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.css
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.less
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/app.less
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/index.esp
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller.c
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/edit.esp
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/list.esp
DEPS_1 += src/paks/esp-html-mvc/templates/esp-html-mvc/start.me
DEPS_1 += src/paks/esp-mvc
DEPS_1 += src/paks/esp-mvc/LICENSE.md
DEPS_1 += src/paks/esp-mvc/package.json
DEPS_1 += src/paks/esp-mvc/README.md
DEPS_1 += src/paks/esp-mvc/templates
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc/appweb.conf
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc/controller.c
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc/migration.c
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc/src
DEPS_1 += src/paks/esp-mvc/templates/esp-mvc/src/app.c
DEPS_1 += src/paks/esp-server
DEPS_1 += src/paks/esp-server/LICENSE.md
DEPS_1 += src/paks/esp-server/package.json
DEPS_1 += src/paks/esp-server/README.md
DEPS_1 += src/paks/esp-server/templates
DEPS_1 += src/paks/esp-server/templates/esp-server
DEPS_1 += src/paks/esp-server/templates/esp-server/appweb.conf
DEPS_1 += src/paks/est
DEPS_1 += src/paks/est/ca.crt
DEPS_1 += src/paks/est/est.h
DEPS_1 += src/paks/est/est.me
DEPS_1 += src/paks/est/estLib.c
DEPS_1 += src/paks/est/LICENSE.md
DEPS_1 += src/paks/est/package.json
DEPS_1 += src/paks/est/README.md
DEPS_1 += src/paks/http
DEPS_1 += src/paks/http/ca.crt
DEPS_1 += src/paks/http/http.c
DEPS_1 += src/paks/http/http.h
DEPS_1 += src/paks/http/http.me
DEPS_1 += src/paks/http/httpLib.c
DEPS_1 += src/paks/http/LICENSE.md
DEPS_1 += src/paks/http/package.json
DEPS_1 += src/paks/http/README.md
DEPS_1 += src/paks/me-dev
DEPS_1 += src/paks/me-dev/dev.es
DEPS_1 += src/paks/me-dev/dev.me
DEPS_1 += src/paks/me-dev/LICENSE.md
DEPS_1 += src/paks/me-dev/package.json
DEPS_1 += src/paks/me-dev/README.md
DEPS_1 += src/paks/me-doc
DEPS_1 += src/paks/me-doc/doc.es
DEPS_1 += src/paks/me-doc/doc.me
DEPS_1 += src/paks/me-doc/gendoc.es
DEPS_1 += src/paks/me-doc/LICENSE.md
DEPS_1 += src/paks/me-doc/package.json
DEPS_1 += src/paks/me-doc/README.md
DEPS_1 += src/paks/me-package
DEPS_1 += src/paks/me-package/LICENSE.md
DEPS_1 += src/paks/me-package/manifest.me
DEPS_1 += src/paks/me-package/package.es
DEPS_1 += src/paks/me-package/package.json
DEPS_1 += src/paks/me-package/package.me
DEPS_1 += src/paks/me-package/README.md
DEPS_1 += src/paks/me-ssl
DEPS_1 += src/paks/me-ssl/LICENSE.md
DEPS_1 += src/paks/me-ssl/matrixssl.me
DEPS_1 += src/paks/me-ssl/nanossl.me
DEPS_1 += src/paks/me-ssl/openssl.me
DEPS_1 += src/paks/me-ssl/package.json
DEPS_1 += src/paks/me-ssl/README.md
DEPS_1 += src/paks/me-ssl/ssl.me
DEPS_1 += src/paks/mpr
DEPS_1 += src/paks/mpr/LICENSE.md
DEPS_1 += src/paks/mpr/makerom.c
DEPS_1 += src/paks/mpr/manager.c
DEPS_1 += src/paks/mpr/mpr.h
DEPS_1 += src/paks/mpr/mpr.me
DEPS_1 += src/paks/mpr/mprLib.c
DEPS_1 += src/paks/mpr/mprSsl.c
DEPS_1 += src/paks/mpr/package.json
DEPS_1 += src/paks/mpr/README.md
DEPS_1 += src/paks/osdep
DEPS_1 += src/paks/osdep/LICENSE.md
DEPS_1 += src/paks/osdep/osdep.h
DEPS_1 += src/paks/osdep/osdep.me
DEPS_1 += src/paks/osdep/package.json
DEPS_1 += src/paks/osdep/README.md
DEPS_1 += src/paks/pcre
DEPS_1 += src/paks/pcre/LICENSE.md
DEPS_1 += src/paks/pcre/package.json
DEPS_1 += src/paks/pcre/pcre.c
DEPS_1 += src/paks/pcre/pcre.h
DEPS_1 += src/paks/pcre/pcre.me
DEPS_1 += src/paks/pcre/README.md
DEPS_1 += src/paks/sqlite
DEPS_1 += src/paks/sqlite/LICENSE.md
DEPS_1 += src/paks/sqlite/package.json
DEPS_1 += src/paks/sqlite/README.md
DEPS_1 += src/paks/sqlite/sqlite.c
DEPS_1 += src/paks/sqlite/sqlite.me
DEPS_1 += src/paks/sqlite/sqlite3.c
DEPS_1 += src/paks/sqlite/sqlite3.h

$(CONFIG)/esp: $(DEPS_1)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0" ; \
	cp esp-html-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/package.json ; \
	cp esp-html-mvc/README.md ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc" ; \
	cp esp-html-mvc/templates/esp-html-mvc/appweb.conf ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/assets" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/css" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.css ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/css/all.css ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.less ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/css/all.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/app.less ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/css/app.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/css/theme.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/index.esp ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/layouts" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/client/layouts/default.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/controller-singleton.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller.c ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/controller.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/edit.esp ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/edit.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/list.esp ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/list.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/start.me ../../$(CONFIG)/esp/esp-html-mvc/1.0.0/templates/esp-html-mvc/start.me ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/1.0.0" ; \
	cp esp-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-mvc/1.0.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(CONFIG)/esp/esp-mvc/1.0.0/package.json ; \
	cp esp-mvc/README.md ../../$(CONFIG)/esp/esp-mvc/1.0.0/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/1.0.0/templates" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc" ; \
	cp esp-mvc/templates/esp-mvc/appweb.conf ../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc/appweb.conf ; \
	cp esp-mvc/templates/esp-mvc/controller.c ../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc/controller.c ; \
	cp esp-mvc/templates/esp-mvc/migration.c ../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc/migration.c ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc/src" ; \
	cp esp-mvc/templates/esp-mvc/src/app.c ../../$(CONFIG)/esp/esp-mvc/1.0.0/templates/esp-mvc/src/app.c ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/1.0.0" ; \
	cp esp-server/LICENSE.md ../../$(CONFIG)/esp/esp-server/1.0.0/LICENSE.md ; \
	cp esp-server/package.json ../../$(CONFIG)/esp/esp-server/1.0.0/package.json ; \
	cp esp-server/README.md ../../$(CONFIG)/esp/esp-server/1.0.0/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/1.0.0/templates" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/1.0.0/templates/esp-server" ; \
	cp esp-server/templates/esp-server/appweb.conf ../../$(CONFIG)/esp/esp-server/1.0.0/templates/esp-server/appweb.conf ; \
	)

#
#   esp.conf
#
DEPS_2 += src/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp.conf $(CONFIG)/bin/esp.conf

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_5)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_6 += $(CONFIG)/inc/me.h
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_6)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_7 += $(CONFIG)/inc/mpr.h
DEPS_7 += $(CONFIG)/inc/me.h
DEPS_7 += $(CONFIG)/inc/osdep.h
DEPS_7 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.so: $(DEPS_7)
	@echo '      [Link] $(CONFIG)/bin/libmpr.so'
	$(CC) -shared -o $(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_8)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_9 += $(CONFIG)/inc/me.h
DEPS_9 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_9)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_10 += $(CONFIG)/inc/pcre.h
DEPS_10 += $(CONFIG)/inc/me.h
DEPS_10 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.so: $(DEPS_10)
	@echo '      [Link] $(CONFIG)/bin/libpcre.so'
	$(CC) -shared -o $(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_11)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_12 += $(CONFIG)/inc/me.h
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_12)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_13 += $(CONFIG)/inc/mpr.h
DEPS_13 += $(CONFIG)/inc/me.h
DEPS_13 += $(CONFIG)/inc/osdep.h
DEPS_13 += $(CONFIG)/obj/mprLib.o
DEPS_13 += $(CONFIG)/bin/libmpr.so
DEPS_13 += $(CONFIG)/inc/pcre.h
DEPS_13 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_13 += $(CONFIG)/bin/libpcre.so
endif
DEPS_13 += $(CONFIG)/inc/http.h
DEPS_13 += $(CONFIG)/obj/httpLib.o

LIBS_13 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_13 += -lpcre
endif

$(CONFIG)/bin/libhttp.so: $(DEPS_13)
	@echo '      [Link] $(CONFIG)/bin/libhttp.so'
	$(CC) -shared -o $(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBPATHS_13) $(LIBS_13) $(LIBS_13) $(LIBS) 
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_14)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/appweb/appweb.h $(CONFIG)/inc/appweb.h

#
#   appwebLib.o
#
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/appweb.h
DEPS_15 += $(CONFIG)/inc/pcre.h
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_15)
	@echo '   [Compile] $(CONFIG)/obj/appwebLib.o'
	$(CC) -c -o $(CONFIG)/obj/appwebLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
DEPS_16 += $(CONFIG)/inc/mpr.h
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/osdep.h
DEPS_16 += $(CONFIG)/obj/mprLib.o
DEPS_16 += $(CONFIG)/bin/libmpr.so
DEPS_16 += $(CONFIG)/inc/pcre.h
DEPS_16 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_16 += $(CONFIG)/bin/libpcre.so
endif
DEPS_16 += $(CONFIG)/inc/http.h
DEPS_16 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_16 += $(CONFIG)/bin/libhttp.so
endif
DEPS_16 += $(CONFIG)/inc/appweb.h
DEPS_16 += $(CONFIG)/obj/appwebLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_16 += -lhttp
endif
LIBS_16 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_16 += -lpcre
endif

$(CONFIG)/bin/libappweb.so: $(DEPS_16)
	@echo '      [Link] $(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o $(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appwebLib.o" $(LIBPATHS_16) $(LIBS_16) $(LIBS_16) $(LIBS) 
endif

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_17)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_19 += $(CONFIG)/inc/sqlite3.h
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.so: $(DEPS_19)
	@echo '      [Link] $(CONFIG)/bin/libsql.so'
	$(CC) -shared -o $(CONFIG)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_20)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/edi.h $(CONFIG)/inc/edi.h

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_21)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp.h $(CONFIG)/inc/esp.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_22)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/mdb.h $(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/edi.h
DEPS_23 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/edi.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/edi.c

#
#   espAbbrev.o
#
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_24)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espFramework.o
#
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/http.h
DEPS_26 += $(CONFIG)/inc/esp.h
DEPS_26 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_26)
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_27 += $(CONFIG)/inc/me.h
DEPS_27 += $(CONFIG)/inc/esp.h
DEPS_27 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_27)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_28 += $(CONFIG)/inc/me.h
DEPS_28 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espTemplate.c

#
#   mdb.o
#
DEPS_29 += $(CONFIG)/inc/me.h
DEPS_29 += $(CONFIG)/inc/http.h
DEPS_29 += $(CONFIG)/inc/edi.h
DEPS_29 += $(CONFIG)/inc/mdb.h
DEPS_29 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/mdb.c $(DEPS_29)
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mdb.c

#
#   sdb.o
#
DEPS_30 += $(CONFIG)/inc/me.h
DEPS_30 += $(CONFIG)/inc/http.h
DEPS_30 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/sdb.o: \
    src/sdb.c $(DEPS_30)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sdb.c

#
#   libmod_esp
#
DEPS_31 += $(CONFIG)/inc/mpr.h
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/osdep.h
DEPS_31 += $(CONFIG)/obj/mprLib.o
DEPS_31 += $(CONFIG)/bin/libmpr.so
DEPS_31 += $(CONFIG)/inc/pcre.h
DEPS_31 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_31 += $(CONFIG)/bin/libpcre.so
endif
DEPS_31 += $(CONFIG)/inc/http.h
DEPS_31 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_31 += $(CONFIG)/bin/libhttp.so
endif
DEPS_31 += $(CONFIG)/inc/appweb.h
DEPS_31 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_31 += $(CONFIG)/bin/libappweb.so
endif
DEPS_31 += $(CONFIG)/inc/sqlite3.h
DEPS_31 += $(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_31 += $(CONFIG)/bin/libsql.so
endif
DEPS_31 += $(CONFIG)/inc/edi.h
DEPS_31 += $(CONFIG)/inc/esp.h
DEPS_31 += $(CONFIG)/inc/mdb.h
DEPS_31 += $(CONFIG)/obj/edi.o
DEPS_31 += $(CONFIG)/obj/espAbbrev.o
DEPS_31 += $(CONFIG)/obj/espFramework.o
DEPS_31 += $(CONFIG)/obj/espHandler.o
DEPS_31 += $(CONFIG)/obj/espHtml.o
DEPS_31 += $(CONFIG)/obj/espTemplate.o
DEPS_31 += $(CONFIG)/obj/mdb.o
DEPS_31 += $(CONFIG)/obj/sdb.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_31 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_31 += -lhttp
endif
LIBS_31 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_31 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_31 += -lsql
endif

$(CONFIG)/bin/libmod_esp.so: $(DEPS_31)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o $(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_31) $(LIBS_31) $(LIBS_31) $(LIBS) 

#
#   esp.o
#
DEPS_32 += $(CONFIG)/inc/me.h
DEPS_32 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp.c $(DEPS_32)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp.c

#
#   espcmd
#
DEPS_33 += $(CONFIG)/inc/mpr.h
DEPS_33 += $(CONFIG)/inc/me.h
DEPS_33 += $(CONFIG)/inc/osdep.h
DEPS_33 += $(CONFIG)/obj/mprLib.o
DEPS_33 += $(CONFIG)/bin/libmpr.so
DEPS_33 += $(CONFIG)/inc/pcre.h
DEPS_33 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_33 += $(CONFIG)/bin/libpcre.so
endif
DEPS_33 += $(CONFIG)/inc/http.h
DEPS_33 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_33 += $(CONFIG)/bin/libhttp.so
endif
DEPS_33 += $(CONFIG)/inc/appweb.h
DEPS_33 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_33 += $(CONFIG)/bin/libappweb.so
endif
DEPS_33 += $(CONFIG)/inc/sqlite3.h
DEPS_33 += $(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_33 += $(CONFIG)/bin/libsql.so
endif
DEPS_33 += $(CONFIG)/inc/edi.h
DEPS_33 += $(CONFIG)/inc/esp.h
DEPS_33 += $(CONFIG)/inc/mdb.h
DEPS_33 += $(CONFIG)/obj/edi.o
DEPS_33 += $(CONFIG)/obj/espAbbrev.o
DEPS_33 += $(CONFIG)/obj/espFramework.o
DEPS_33 += $(CONFIG)/obj/espHandler.o
DEPS_33 += $(CONFIG)/obj/espHtml.o
DEPS_33 += $(CONFIG)/obj/espTemplate.o
DEPS_33 += $(CONFIG)/obj/mdb.o
DEPS_33 += $(CONFIG)/obj/sdb.o
DEPS_33 += $(CONFIG)/bin/libmod_esp.so
DEPS_33 += $(CONFIG)/obj/esp.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_33 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_33 += -lhttp
endif
LIBS_33 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_33 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_33 += -lsql
endif
LIBS_33 += -lmod_esp

$(CONFIG)/bin/esp: $(DEPS_33)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_33) $(LIBS_33) $(LIBS_33) $(LIBS) $(LIBS) 


#
#   http-ca-crt
#
DEPS_34 += src/paks/http/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_34)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/http/ca.crt $(CONFIG)/bin/ca.crt

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_35)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_36 += $(CONFIG)/inc/me.h
DEPS_36 += $(CONFIG)/inc/est.h
DEPS_36 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_36)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_37 += $(CONFIG)/inc/est.h
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/osdep.h
DEPS_37 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.so: $(DEPS_37)
	@echo '      [Link] $(CONFIG)/bin/libest.so'
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_38)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_39 += $(CONFIG)/inc/mpr.h
DEPS_39 += $(CONFIG)/inc/me.h
DEPS_39 += $(CONFIG)/inc/osdep.h
DEPS_39 += $(CONFIG)/obj/mprLib.o
DEPS_39 += $(CONFIG)/bin/libmpr.so
DEPS_39 += $(CONFIG)/inc/est.h
DEPS_39 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_39 += $(CONFIG)/bin/libest.so
endif
DEPS_39 += $(CONFIG)/obj/mprSsl.o

LIBS_39 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_39 += -lssl
    LIBPATHS_39 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_39 += -lcrypto
    LIBPATHS_39 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_39 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_39 += -lmatrixssl
    LIBPATHS_39 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_39 += -lssls
    LIBPATHS_39 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmprssl.so: $(DEPS_39)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_39) $(LIBS_39) $(LIBS_39) $(LIBS) 

#
#   sqlite.o
#
DEPS_40 += $(CONFIG)/inc/me.h
DEPS_40 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_40)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_41 += $(CONFIG)/inc/sqlite3.h
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/obj/sqlite3.o
DEPS_41 += $(CONFIG)/bin/libsql.so
DEPS_41 += $(CONFIG)/obj/sqlite.o

LIBS_41 += -lsql

$(CONFIG)/bin/sqlite: $(DEPS_41)
	@echo '      [Link] $(CONFIG)/bin/sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBPATHS_41) $(LIBS_41) $(LIBS_41) $(LIBS) $(LIBS) 
endif

#
#   stop
#
stop: $(DEPS_42)

#
#   installBinary
#
installBinary: $(DEPS_43)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "1.0.0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	cp $(CONFIG)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp $(CONFIG)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(CONFIG)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(CONFIG)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(CONFIG)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(CONFIG)/bin/libsql.so $(ME_VAPP_PREFIX)/bin/libsql.so ; \
	cp $(CONFIG)/bin/libmod_esp.so $(ME_VAPP_PREFIX)/bin/libmod_esp.so ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libssl*.so* $(ME_VAPP_PREFIX)/bin/libssl*.so* ; \
	cp $(CONFIG)/bin/libcrypto*.so* $(ME_VAPP_PREFIX)/bin/libcrypto*.so* ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	fi ; \
	cp $(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	cp $(CONFIG)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(CONFIG)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/esp/me.h" ; \
	cp src/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/esp/esp.h" ; \
	cp src/edi.h $(ME_VAPP_PREFIX)/inc/edi.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/edi.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/edi.h" "$(ME_INC_PREFIX)/esp/edi.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	cp src/paks/appweb/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/esp/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/esp/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	)

#
#   start
#
start: $(DEPS_44)

#
#   install
#
DEPS_45 += stop
DEPS_45 += installBinary
DEPS_45 += start

install: $(DEPS_45)

#
#   uninstall
#
DEPS_46 += stop

uninstall: $(DEPS_46)
	( \
	cd .; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#
version: $(DEPS_47)
	echo 1.0.0



INSTALL?=install

sysprefix?=/usr
prefix?=${sysprefix}
sysconfdir?=${prefix}/etc
sbindir?=${sysprefix}/sbin
libexecdir?=${sysprefix}/libexec

all:

install:
	sed -i "s,/libexec,$(libexecdir)," update-uboot create-preboot-script

	$(INSTALL) -m 755 -d $(DESTDIR)$(sysconfdir)
	$(INSTALL) -m 755 -d $(DESTDIR)$(sbindir)
	$(INSTALL) -m 755 -d $(DESTDIR)$(libexecdir)/ubm
	
	$(INSTALL) -m 644 uboot.cfg $(DESTDIR)$(sysconfdir)
	$(INSTALL) -m 755 update-uboot create-preboot-script $(DESTDIR)$(sbindir)
	$(INSTALL) -m 755 ubm_common.sh $(DESTDIR)$(libexecdir)/ubm

postinst:
	# do not fail if we cannot flash uboot
	# the uboot pkg might get installed after us and it should call update-uboot again
	(update-uboot; RES="$$?"; [ "$${RES}" == "2" ] && exit 0 || exit $${RES}; )

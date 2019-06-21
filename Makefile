
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
	update-uboot

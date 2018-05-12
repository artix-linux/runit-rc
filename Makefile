SYSCONFDIR = /etc
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
LIBDIR = $(PREFIX)/lib

RCDIR = $(SYSCONFDIR)/rc
RCLIBDIR = $(LIBDIR)/rc
RCSVDIR = $(RCDIR)/sv.d
RCRUNDIR = /run/sv.d

RCBIN = \
	script/rc-sysinit \
	script/rc-shutdown \
	script/rc-sv \
	script/modules-load

RCSVD = \
	sv.d/root \
	sv.d/binfmt \
	sv.d/bootlogd \
	sv.d/cleanup \
	sv.d/console-setup \
	sv.d/dmesg \
	sv.d/hostname \
	sv.d/hwclock \
	sv.d/kmod-static-nodes \
	sv.d/misc \
	sv.d/mount-all \
	sv.d/net-lo \
	sv.d/netfs \
	sv.d/random-seed \
	sv.d/remount-root \
	sv.d/swap \
	sv.d/sysctl \
	sv.d/sysusers \
	sv.d/tmpfiles-dev \
	sv.d/tmpfiles-setup \
	sv.d/udev \
	sv.d/udev-trigger \
	sv.d/udev-settle \
	sv.d/modules \
	sv.d/sysfs \
	sv.d/devfs \
	sv.d/procfs \
	sv.d/cgroups

# 	sv.d/timezone \
# 	sv.d/lvm-monitoring \
# 	sv.d/lvm \
# 	sv.d/cryptsetup

CONF = script/rc.conf

RCFUNC = script/functions script/cgroup-release-agent

LN = ln -sf
CP = cp -R --no-dereference --preserve=mode,links -v
RM = rm -f
RMD = rm -fr --one-file-system
M4 = m4 -P
CHMODAW = chmod a-w
CHMODX = chmod +x

EDIT = sed \
	-e "s|@RCDIR[@]|$(RCDIR)|g" \
	-e "s|@RCLIBDIR[@]|$(RCLIBDIR)|g" \
	-e "s|@RCRUNDIR[@]|$(RCRUNDIR)|g"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@$(M4) $@.in | $(EDIT) >$@
	@$(CHMODAW) "$@"
	@$(CHMODX) "$@"

all: all-rc

all-rc: $(RCBIN) $(RCSVD) $(RCFUNC) $(CONF)

install-rc:

	install -d $(DESTDIR)$(RCDIR)
	install -m755 $(CONF) $(DESTDIR)$(RCDIR)

	install -d $(DESTDIR)$(BINDIR)
	install -m755 $(RCBIN) $(DESTDIR)$(BINDIR)

	install -d $(DESTDIR)$(RCLIBDIR)
	install -m755 $(RCFUNC) $(DESTDIR)$(RCLIBDIR)

	install -d $(DESTDIR)$(RCSVDIR)
	install -m755 $(RCSVD) $(DESTDIR)$(RCSVDIR)

	install -d $(DESTDIR)$(RCDIR)/sysinit
	$(CP) sysinit $(DESTDIR)$(RCDIR)/

	install -d $(DESTDIR)$(RCDIR)/shutdown
	$(CP) shutdown $(DESTDIR)$(RCDIR)/

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 script/modules-load.8 $(DESTDIR)$(MANDIR)/man8

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSVD) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc

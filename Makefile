SYSCONFDIR = /etc
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
LIBDIR = $(PREFIX)/lib

RCDIR = $(SYSCONFDIR)/rc
RCLIBDIR = $(LIBDIR)/rc
RCSVDIR = $(RCLIBDIR)/sv.d
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

# SYSINIT = \
# 	01-sysfs \
# 	02-procfs \
# 	03-devfs \
# 	04-cgroups \
# 	05-root \
# 	10-hostname \
# 	15-hwclock \
# 	20-kmod-static-nodes \
# 	25-tmpfiles-dev \
# 	30-udev \
# 	31-udev-trigger \
# 	32-modules \
# 	33-udev-settle \
# 	40-console-setup \
# 	45-net-lo \
# 	50-misc \
# 	55-remount-root \
# 	60-mount-all \
# 	65-swap \
# 	70-random-seed \
# 	75-tmpfiles-setup \
# 	80-sysusers \
# 	85-dmesg \
# 	90-sysctl \
# 	95-binfmt \
# 	99-cleanup
#
# SHUTDWON = \
# 	10-random-seed \
# 	20-cleanup \
# 	30-udev \
# 	40-misc \
# 	50-swap \
# 	60-root \
# 	70-remount-root

# 	sv.d/timezone \
# 	sv.d/lvm-monitoring \
# 	sv.d/lvm \
# 	sv.d/cryptsetup

CONF = script/rc.conf

RCFUNC = script/functions script/cgroup-release-agent

LN = ln -sf
RM = rm -f
RMD = rm -fr --one-file-system
M4 = m4 -P
CHMODAW = chmod a-w
CHMODX = chmod +x

EDIT = sed \
	-e "s|@RCDIR[@]|$(RCDIR)|g" \
	-e "s|@RCLIBDIR[@]|$(RCLIBDIR)|g" \
	-e "s|@RCSVDIR[@]|$(RCSVDIR)|g" \
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

	$(LN) $(RCSVDIR)/sysfs $(DESTDIR)$(RCDIR)/sysinit/01-sysfs
	$(LN) $(RCSVDIR)/procfs $(DESTDIR)$(RCDIR)/sysinit/02-procfs
	$(LN) $(RCSVDIR)/devfs $(DESTDIR)$(RCDIR)/sysinit/03-devfs
	$(LN) $(RCSVDIR)/cgroups $(DESTDIR)$(RCDIR)/sysinit/04-cgroups
	$(LN) $(RCSVDIR)/root $(DESTDIR)$(RCDIR)/sysinit/05-root
	$(LN) $(RCSVDIR)/hostname $(DESTDIR)$(RCDIR)/sysinit/10-hostname
	$(LN) $(RCSVDIR)/hwclock $(DESTDIR)$(RCDIR)/sysinit/15-hwclock
	$(LN) $(RCSVDIR)/kmod-static-nodes $(DESTDIR)$(RCDIR)/sysinit/20-kmod-static-nodes
	$(LN) $(RCSVDIR)/tmpfiles-dev $(DESTDIR)$(RCDIR)/sysinit/25-tmpfiles-dev
	$(LN) $(RCSVDIR)/udev $(DESTDIR)$(RCDIR)/sysinit/30-udev
	$(LN) $(RCSVDIR)/udev-trigger $(DESTDIR)$(RCDIR)/sysinit/31-udev-trigger
	$(LN) $(RCSVDIR)/modules $(DESTDIR)$(RCDIR)/sysinit/32-modules
	$(LN) $(RCSVDIR)/udev-settle $(DESTDIR)$(RCDIR)/sysinit/33-udev-settle
	$(LN) $(RCSVDIR)/console-setup $(DESTDIR)$(RCDIR)/sysinit/40-console-setup
	$(LN) $(RCSVDIR)/net-lo $(DESTDIR)$(RCDIR)/sysinit/45-net-lo
	$(LN) $(RCSVDIR)/misc $(DESTDIR)$(RCDIR)/sysinit/50-misc
	$(LN) $(RCSVDIR)/remount-root $(DESTDIR)$(RCDIR)/sysinit/55-remount-root
	$(LN) $(RCSVDIR)/mount-all $(DESTDIR)$(RCDIR)/sysinit/60-mount-all
	$(LN) $(RCSVDIR)/swap $(DESTDIR)$(RCDIR)/sysinit/65-swap
	$(LN) $(RCSVDIR)/random-seed $(DESTDIR)$(RCDIR)/sysinit/70-random-seed
	$(LN) $(RCSVDIR)/tmpfiles-setup $(DESTDIR)$(RCDIR)/sysinit/75-tmpfiles-setup
	$(LN) $(RCSVDIR)/sysusers $(DESTDIR)$(RCDIR)/sysinit/80-sysusers
	$(LN) $(RCSVDIR)/dmesg $(DESTDIR)$(RCDIR)/sysinit/85-dmesg
	$(LN) $(RCSVDIR)/sysctl $(DESTDIR)$(RCDIR)/sysinit/90-sysctl
	$(LN) $(RCSVDIR)/binfmt $(DESTDIR)$(RCDIR)/sysinit/95-binfmt
	$(LN) $(RCSVDIR)/cleanup $(DESTDIR)$(RCDIR)/sysinit/99-cleanup

	install -d $(DESTDIR)$(RCDIR)/shutdown

	$(LN) $(RCSVDIR)/random-seed $(DESTDIR)$(RCDIR)/shutdown/10-random-seed
	$(LN) $(RCSVDIR)/cleanup $(DESTDIR)$(RCDIR)/shutdown/20-cleanup
	$(LN) $(RCSVDIR)/udev $(DESTDIR)$(RCDIR)/shutdown/30-udev
	$(LN) $(RCSVDIR)/hwclock $(DESTDIR)$(RCDIR)/sysinit/35-hwclock
	$(LN) $(RCSVDIR)/misc $(DESTDIR)$(RCDIR)/shutdown/40-misc
	$(LN) $(RCSVDIR)/swap $(DESTDIR)$(RCDIR)/shutdown/50-swap
	$(LN) $(RCSVDIR)/root $(DESTDIR)$(RCDIR)/shutdown/60-root
	$(LN) $(RCSVDIR)/remount-root $(DESTDIR)$(RCDIR)/shutdown/70-remount-root

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 script/modules-load.8 $(DESTDIR)$(MANDIR)/man8

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSVD) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc

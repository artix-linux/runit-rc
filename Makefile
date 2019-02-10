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
    sv.d/binfmt \
    sv.d/cgroups \
    sv.d/cleanup \
    sv.d/console-setup \
    sv.d/fsck \
    sv.d/hostname \
    sv.d/hwclock \
    sv.d/kmod-static-nodes \
    sv.d/modules \
    sv.d/mount-fs \
    sv.d/net-lo \
    sv.d/pseudofs \
    sv.d/random-seed \
    sv.d/swap \
    sv.d/sysctl \
    sv.d/tmpfiles-dev \
    sv.d/udev

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

	$(LN) $(RCSVDIR)/pseudofs $(DESTDIR)$(RCDIR)/sysinit/01-pseudofs
	$(LN) $(RCSVDIR)/cgroups $(DESTDIR)$(RCDIR)/sysinit/02-cgroups
	$(LN) $(RCSVDIR)/kmod-static-nodes $(DESTDIR)$(RCDIR)/sysinit/03-kmod-static-nodes
	$(LN) $(RCSVDIR)/modules $(DESTDIR)$(RCDIR)/sysinit/04-modules
	$(LN) $(RCSVDIR)/tmpfiles-dev $(DESTDIR)$(RCDIR)/sysinit/05-tmpfiles-dev
	$(LN) $(RCSVDIR)/udev $(DESTDIR)$(RCDIR)/sysinit/06-udev
	$(LN) $(RCSVDIR)/console-setup $(DESTDIR)$(RCDIR)/sysinit/10-console-setup
	$(LN) $(RCSVDIR)/hwclock $(DESTDIR)$(RCDIR)/sysinit/15-hwclock
	$(LN) $(RCSVDIR)/fsck $(DESTDIR)$(RCDIR)/sysinit/20-fsck
	$(LN) $(RCSVDIR)/mount-fs $(DESTDIR)$(RCDIR)/sysinit/30-mount-fs
	$(LN) $(RCSVDIR)/swap $(DESTDIR)$(RCDIR)/sysinit/31-swap
	$(LN) $(RCSVDIR)/random-seed $(DESTDIR)$(RCDIR)/sysinit/40-modules
	$(LN) $(RCSVDIR)/net-lo $(DESTDIR)$(RCDIR)/sysinit/41-net-lo
	$(LN) $(RCSVDIR)/hostname $(DESTDIR)$(RCDIR)/sysinit/42-hostname
	$(LN) $(RCSVDIR)/sysctl $(DESTDIR)$(RCDIR)/sysinit/55-sysctl
	$(LN) $(RCSVDIR)/binfmt $(DESTDIR)$(RCDIR)/sysinit/90-binfmt
	$(LN) $(RCSVDIR)/cleanup $(DESTDIR)$(RCDIR)/sysinit/99-cleanup

	install -d $(DESTDIR)$(RCDIR)/shutdown

	$(LN) $(RCSVDIR)/random-seed $(DESTDIR)$(RCDIR)/shutdown/10-random-seed
	$(LN) $(RCSVDIR)/hwclock $(DESTDIR)$(RCDIR)/shutdown/15-hwclock
	$(LN) $(RCSVDIR)/udev $(DESTDIR)$(RCDIR)/shutdown/30-udev
	$(LN) $(RCSVDIR)/cleanup $(DESTDIR)$(RCDIR)/shutdown/20-cleanup
	$(LN) $(RCSVDIR)/swap $(DESTDIR)$(RCDIR)/shutdown/50-swap
	$(LN) $(RCSVDIR)/mount-fs $(DESTDIR)$(RCDIR)/shutdown/60-mount-fs

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 script/modules-load.8 $(DESTDIR)$(MANDIR)/man8

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSVD) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc

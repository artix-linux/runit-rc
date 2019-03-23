SYSCONFDIR = /etc
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
LIBDIR = $(PREFIX)/lib

RCDIR = $(SYSCONFDIR)/rc
RCLIBDIR = $(LIBDIR)/rc
RCSVDIR = /etc/rc/sv.d
RCRUNDIR = /run/sv.d

RCBIN = \
	script/rc-sysinit \
	script/rc-shutdown \
	script/rc-sv \
	script/modules-load

RCSTAGE1 = \
    stage1/00-pseudofs \
    stage1/01-cgroups \
    stage1/01-static-devnodes \
    stage1/02-modules \
    stage1/02-udev \
    stage1/03-console-setup \
    stage1/03-hwclock \
    stage1/04-rootfs \
    stage1/06-cryptsetup \
    stage1/06-fsck \
    stage1/07-mountfs \
    stage1/08-misc \
    stage1/11-sysctl \
    stage1/99-cleanup

RCSTAGE3 = \
	stage3/cryptsetup

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

all-rc: $(RCBIN) $(RCSVD) $(RCSTAGE1) $(RCFUNC) $(CONF)

install-rc:

	install -d $(DESTDIR)$(RCDIR)
	install -m755 $(CONF) $(DESTDIR)$(RCDIR)

	install -d $(DESTDIR)$(BINDIR)
	install -m755 $(RCBIN) $(DESTDIR)$(BINDIR)

	install -d $(DESTDIR)$(RCLIBDIR)
	install -m755 $(RCFUNC) $(DESTDIR)$(RCLIBDIR)

	install -d $(DESTDIR)$(RCSVDIR)
	install -m755 $(RCSVD) $(DESTDIR)$(RCSVDIR)

	install -d $(DESTDIR)$(RCDIR)/stage1

	install -m644 $(DESTDIR)$(RCDIR)/stage1/

	install -d $(DESTDIR)$(RCDIR)/shutdown

	$(LN) $(RCSVDIR)/random-seed $(DESTDIR)$(RCDIR)/shutdown/10-random-seed
	$(LN) $(RCSVDIR)/cleanup $(DESTDIR)$(RCDIR)/shutdown/20-cleanup
	$(LN) $(RCSVDIR)/udev $(DESTDIR)$(RCDIR)/shutdown/30-udev
	$(LN) $(RCSVDIR)/misc $(DESTDIR)$(RCDIR)/shutdown/40-misc
	$(LN) $(RCSVDIR)/swap $(DESTDIR)$(RCDIR)/shutdown/50-swap
	$(LN) $(RCSVDIR)/root $(DESTDIR)$(RCDIR)/shutdown/60-root
	$(LN) $(RCSVDIR)/remount-root $(DESTDIR)$(RCDIR)/shutdown/70-remount-root

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 script/modules-load.8 $(DESTDIR)$(MANDIR)/man8

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSTAGE1) $(RCSVD) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc

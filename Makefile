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

	install -d $(DESTDIR)$(RCLIBDIR)/stage1
	install -m755 $(DESTDIR)$(RCLIBDIR)/stage1/

	install -d $(DESTDIR)$(RCLIBDIR)/stage3/
	install -m755 $(DESTDIR)$(RCLIBDIR)/stage3/

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 script/modules-load.8 $(DESTDIR)$(MANDIR)/man8

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSTAGE1) $(RCSVD) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc

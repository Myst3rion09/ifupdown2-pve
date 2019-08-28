include /usr/share/dpkg/pkg-info.mk

PACKAGE=ifupdown2

SRCDIR=ifupdown2
BUILDDIR=${SRCDIR}.tmp

GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb

all: ${DEB}
	@echo ${DEB}

.PHONY: submodule
submodule:
	test -f "${SRCDIR}/debian/changelog" || git submodule update --init

.PHONY: deb
deb: ${DEB}
${DEB}: | submodule
	rm -f *.deb
	rm -rf $(BUILDDIR)
	mkdir $(BUILDDIR)
	cp -a $(SRCDIR)/* $(BUILDDIR)/
	cp -R debian/* $(BUILDDIR)/debian/
	cd ${BUILDDIR}; dpkg-buildpackage -rfakeroot -b -uc -us

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh -X repoman@repo.proxmox.com -- upload --product pve --dist stretch

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf ${BUILDDIR} *.deb *.changes *.dsc *.buildinfo

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

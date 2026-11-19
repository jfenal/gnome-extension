# COPR "make_srpm" build method: COPR runs, as root in a fresh chroot,
#   make -f .copr/Makefile srpm outdir=<dir> spec=<spec>
# from the root of a clone of this repository.

outdir ?= $(CURDIR)/build

.PHONY: srpm

srpm:
	dnf -y install git rpm-build
	git config --global --add safe.directory "$(CURDIR)"
	packaging/build-rpm.sh --srpm "$(outdir)"

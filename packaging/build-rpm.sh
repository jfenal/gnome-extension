#!/bin/sh
# Build the RPM from this git checkout.
#
# Archives the current tree (HEAD plus uncommitted changes to tracked files)
# as the spec's Source0 tarball and runs rpmbuild under build/rpmbuild.
#
# The Release is a git snapshot, 1.<commit date>git<short hash>, so every
# commit sorts after the previous one and dnf picks up new builds.
#
# Usage:
#   packaging/build-rpm.sh                  binary + source RPM in build/
#   packaging/build-rpm.sh --srpm OUTDIR    source RPM only, in OUTDIR (COPR)
set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO"

MODE=-ba
OUTDIR="$REPO/build"
if [ "${1:-}" = --srpm ]; then
    MODE=-bs
    OUTDIR=${2:?--srpm needs an output directory}
fi

TOP="$REPO/build/rpmbuild"
rm -rf "$TOP"
mkdir -p "$TOP/SOURCES" "$TOP/SPECS" "$OUTDIR"

DATE=$(git log -1 --format=%cd --date=format:%Y%m%d%H%M)
HASH=$(git rev-parse --short HEAD)
SPEC="$TOP/SPECS/gnome-shell-extension-netbird.spec"
sed "s/^Release:.*/Release:        1.${DATE}git${HASH}%{?dist}/" \
    packaging/gnome-shell-extension-netbird.spec > "$SPEC"

NAME=$(rpmspec -q --srpm --qf '%{name}' "$SPEC")
VERSION=$(rpmspec -q --srpm --qf '%{version}' "$SPEC")

# `git stash create` snapshots the working tree without touching it; it prints
# nothing when there are no local changes, in which case HEAD is used.
REF=$(git stash create)
git archive --format=tar.gz --prefix="$NAME-$VERSION/" \
    -o "$TOP/SOURCES/$NAME-$VERSION.tar.gz" "${REF:-HEAD}"

rpmbuild "$MODE" --define "_topdir $TOP" "$SPEC"

find "$TOP/RPMS" "$TOP/SRPMS" -name '*.rpm' -exec cp {} "$OUTDIR/" \; 2>/dev/null
ls -1 "$OUTDIR"/*.rpm

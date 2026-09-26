#!/bin/sh
set -eu

TOPDIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
TMPDIR_KING="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_KING"' EXIT

OPENCLASH_REPO="https://github.com/vernesong/OpenClash.git"
OPENCLASH_COMMIT="c3a33c1d3407956fdf8f0e0b7c1a4c52e6ad9593"

ARGON_REPO="https://github.com/jerrykuku/luci-theme-argon.git"
ARGON_COMMIT="136eb5d42f30554e89cc737fd90f503909810660"

echo "===== OpenClash ${OPENCLASH_COMMIT} ====="

git init -q "$TMPDIR_KING/OpenClash"
git -C "$TMPDIR_KING/OpenClash" remote add origin "$OPENCLASH_REPO"
git -C "$TMPDIR_KING/OpenClash" config core.sparseCheckout true

mkdir -p "$TMPDIR_KING/OpenClash/.git/info"
printf '%s\n' '/luci-app-openclash/' \
    > "$TMPDIR_KING/OpenClash/.git/info/sparse-checkout"

git -C "$TMPDIR_KING/OpenClash" fetch \
    --depth=1 origin "$OPENCLASH_COMMIT"

git -C "$TMPDIR_KING/OpenClash" checkout \
    --detach FETCH_HEAD

rm -rf "$TOPDIR/package/luci-app-openclash"

cp -a \
    "$TMPDIR_KING/OpenClash/luci-app-openclash" \
    "$TOPDIR/package/luci-app-openclash"


echo "===== Argon ${ARGON_COMMIT} ====="

git init -q "$TMPDIR_KING/argon"
git -C "$TMPDIR_KING/argon" remote add origin "$ARGON_REPO"

git -C "$TMPDIR_KING/argon" fetch \
    --depth=1 origin "$ARGON_COMMIT"

git -C "$TMPDIR_KING/argon" checkout \
    --detach FETCH_HEAD

rm -rf "$TMPDIR_KING/argon/.git"
rm -rf "$TOPDIR/package/luci-theme-argon"

cp -a \
    "$TMPDIR_KING/argon" \
    "$TOPDIR/package/luci-theme-argon"


echo '===== Verify ====='

grep -E '^PKG_VERSION' \
    "$TOPDIR/package/luci-app-openclash/Makefile"

grep -E 'LUCI_TITLE|PKG_VERSION|PKG_RELEASE' \
    "$TOPDIR/package/luci-theme-argon/Makefile"

echo "OpenClash commit: $OPENCLASH_COMMIT"
echo "Argon commit:     $ARGON_COMMIT"

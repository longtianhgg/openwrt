#!/bin/sh

set -e -x

if [ $# -ne 6 ]; then
    echo "SYNTAX: $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size> <idb image>"
    exit 1
fi

OUTPUT="$1"
BOOTFS="$2"
ROOTFS="$3"
BOOTFSSIZE="$4"
ROOTFSSIZE="$5"
IDB="$6"

IDB_EXPECTED_SIZE=105472
IDB_EXPECTED_SHA256="84c08dd990738c1e935f86206a062aa75effc1148039328b5aa1722db818f8e3"
IDB_SECTOR=64

if [ ! -f "$IDB" ]; then
    echo "ERROR: KING3288 IDB blob not found: $IDB"
    exit 1
fi

IDB_SIZE="$(wc -c < "$IDB")"
IDB_SHA256="$(sha256sum "$IDB" | awk '{print $1}')"

if [ "$IDB_SIZE" -ne "$IDB_EXPECTED_SIZE" ]; then
    echo "ERROR: invalid KING3288 IDB size: $IDB_SIZE"
    exit 1
fi

if [ "$IDB_SHA256" != "$IDB_EXPECTED_SHA256" ]; then
    echo "ERROR: invalid KING3288 IDB SHA256: $IDB_SHA256"
    exit 1
fi

IDB_SECTORS="$((IDB_SIZE / 512))"

align=4096
head=4
sect=63
boot_type=c
rootfs_type=83

set -- $(ptgen \
    -o "$OUTPUT" \
    -h "$head" \
    -s "$sect" \
    -l "$align" \
    -t "$boot_type" -p "${BOOTFSSIZE}M" \
    -t "$rootfs_type" -p "${ROOTFSSIZE}M")

BOOTOFFSET="$(($1 / 512))"
ROOTFSOFFSET="$(($3 / 512))"

if [ "$BOOTOFFSET" -le "$((IDB_SECTOR + IDB_SECTORS - 1))" ]; then
    echo "ERROR: KING3288 IDB overlaps boot partition"
    exit 1
fi

ROOTFSSIZE_SECTORS="$(($4 / 512))"
ROOTFSIMGSIZE="$((($(wc -c < "$ROOTFS") + 511) / 512))"
ROOTFSPADDINGSIZE="$(($ROOTFSSIZE_SECTORS - $ROOTFSIMGSIZE))"
ROOTFSPADDINGOFFSET="$(($ROOTFSOFFSET + $ROOTFSIMGSIZE))"

if [ "$ROOTFSPADDINGSIZE" -gt 2048 ]; then
    ROOTFSPADDINGSIZE=2048
fi

# Vendor SD boot IDB/miniloader, verified on KING3288.
dd bs=512 if="$IDB" of="$OUTPUT" \
    seek="$IDB_SECTOR" \
    count="$IDB_SECTORS" \
    conv=notrunc

dd bs=512 if="$BOOTFS" of="$OUTPUT" \
    seek="$BOOTOFFSET" conv=notrunc

dd bs=512 if="$ROOTFS" of="$OUTPUT" \
    seek="$ROOTFSOFFSET" conv=notrunc,sync

if [ "$ROOTFSPADDINGSIZE" -gt 0 ]; then
    dd bs=512 if=/dev/zero of="$OUTPUT" \
        seek="$ROOTFSPADDINGOFFSET" \
        count="$ROOTFSPADDINGSIZE" \
        conv=notrunc
fi

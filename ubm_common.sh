#! /bin/bash
#
# Source: https://github.com/anyc/uboot-manager
# License: GPLv2
#
# Written by Mario Kicherer (http://kicherer.org)
#

. /etc/uboot.cfg

# default values
UBM_ROOT_DEV=${UBM_ROOT_DEV-/dev/mmcblk0p2}
if command -v findmnt >/dev/null; then
	UBM_LOCAL_ROOT_DEV=${UBM_LOCAL_ROOT_DEV-$(findmnt -nvo source  /)}
else
	UBM_LOCAL_ROOT_DEV=${UBM_LOCAL_ROOT_DEV-$(df --output=source / | tail -n1)}
fi
UBM_KERNEL_ARGS=${UBM_KERNEL_ARGS-rootfstype=btrfs quiet splash logo.nologo}
UBM_MENU_TIMEOUT=${UBM_MENU_TIMEOUT-2}
UBM_DEFAULT=${UBM_DEFAULT-boot0}
UBM_PREPEND_FW_KERNEL_ARGS=${UBM_PREPEND_FW_KERNEL_ARGS-1}
UBM_PRELOADED_DEVTREE=${UBM_PRELOADED_DEVTREE-0}
UBM_DEVTREE_FILE=${UBM_DEVTREE_FILE-bcm2709-rpi-2-b.dtb}
UBM_KERNEL_LADDR_ID=${UBM_KERNEL_LADDR_ID-kernel_addr_r}
UBM_INITRD_LADDR_ID=${UBM_INITRD_LADDR_ID-ramdisk_addr_r}
UBM_SCRIPT_LADDR_ID=${UBM_INITRD_LADDR_ID-script_addr_r}
[ -z ${UBM_KERNEL_PATTERNS} ] && UBM_KERNEL_PATTERNS=("vmlinuz*" "zImage*" "Image*" "xipImage*" "uImage*")
[ -z ${UBM_INITRD_PATTERNS} ] && UBM_INITRD_PATTERNS=("initramfs.cpio.ugz*" "initrd.uimg*")
# bootz for arm32, booti for arm64, zboot x86
UBM_BOOT_CMD=${UBM_BOOT_CMD-bootz}
UBM_KERNEL_DIR=${UBM_KERNEL_DIR-boot}
UBM_FW_DIR=${UBM_FW_DIR-boot/firmware}
UBM_SYSROOT=${UBM_SYSROOT}
UBM_PART_ID=${UBM_PART_ID-mmc 0:1}

UBM_SUBVOL_SEARCH=${UBM_SUBVOL_SEARCH-0}
UBM_BTRFS_VOLUME_PREFIX=${UBM_BTRFS_VOLUME_PREFIX-@root}

UBM_FLASH_UBOOT=${UBM_FLASH_UBOOT-0}
UBM_FLASH_SOURCE_DIR=${UBM_FLASH_SOURCE_DIR-boot}
UBM_FLASH_BINARY=${UBM_FLASH_BINARY-u-boot.imx}
UBM_FLASH_DD_PARAMS=${UBM_FLASH_DD_PARAMS-bs=1k seek=1}
if [ -z "${UBM_FLASH_DEVICE}" ]; then
	if [[ ${UBM_LOCAL_ROOT_DEV} =~ [0-9]$ ]] && [ -b ${UBM_LOCAL_ROOT_DEV::-1} ]; then
		UBM_FLASH_DEVICE="${UBM_LOCAL_ROOT_DEV::-1}"
	elif [[ ${UBM_LOCAL_ROOT_DEV} =~ p[0-9]$ ]] && [ -b ${UBM_LOCAL_ROOT_DEV::-2} ]; then
		UBM_FLASH_DEVICE="${UBM_LOCAL_ROOT_DEV::-2}"
	elif [[ ${UBM_LOCAL_ROOT_DEV} =~ [0-9]$ ]] && [[ "${UBM_LOCAL_ROOT_DEV}" == "/dev/mapper/"* ]] && \
			[ -b /dev/$(basename "${UBM_LOCAL_ROOT_DEV::-1}") ]; then
		UBM_FLASH_DEVICE="/dev/$(basename "${UBM_LOCAL_ROOT_DEV::-1}")"
	elif [[ ${UBM_LOCAL_ROOT_DEV} =~ p[0-9]$ ]] && [[ "${UBM_LOCAL_ROOT_DEV}" == "/dev/mapper/"* ]] && \
			[ -b /dev/$(basename "${UBM_LOCAL_ROOT_DEV::-2}") ]; then
		UBM_FLASH_DEVICE="/dev/$(basename "${UBM_LOCAL_ROOT_DEV::-2}")"
	else
		echo "could not determine \$UBM_FLASH_DEVICE from ${UBM_LOCAL_ROOT_DEV}"
		exit 1
	fi
fi

UBM_FS_LOAD=${UBM_FS_LOAD-load}
UBM_FS_WRITE=${UBM_FS_WRITE-write}

function cleanup {
	[ "${VERBOSE}" ] && echo "cleaning up..."
	
	trap - EXIT
	set +e
	
	[ -d "${TMP_DIR}" ] && mountpoint "${TMP_DIR}" > /dev/null && umount "${TMP_DIR}" || :
	
	[ -d "${TMP_DIR}" ] && rmdir "${TMP_DIR}"
	
	# TODO backup and restore original env
}

# check if mkimage tool is installed
command -v mkimage >/dev/null || { echo "missing mkimage"; exit 1; }

if [ -d /etc/uboot.cfg.d/ ]; then
	for script in /etc/uboot.cfg.d/*; do
		[[ -x "${script}" ]] && source "${script}"
	done
fi

trap cleanup EXIT

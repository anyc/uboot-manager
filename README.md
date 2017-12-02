
uboot-manager
=============

Uboot-manager is a tool to automate the boot configuration of uboot.
A central task of this tool is to search for installed kernels and configure
uboot to boot the most recent kernel by default.

Example
-------

After the uboot initialization messages, the created script creates 

    Available boot options:
    -----------------------
       "run boot0" will boot vmlinuz-4.1.16-rpi
       "run boot1" will boot vmlinuz-4.1.15-rpi

    writing boot-failure-check
    1 bytes written
    Will execute "run boot0" in 2 seconds, abort with CTRL+c...

By default, output to HDMI screen is disabled and only in case of an error
a message is shown. This can be changed by setting UBOOT_STDOUT in
/etc/uboot.cfg accordingly.

Handling faults
---------------

Uboot-manager offers two mechanisms to alter the boot process if the
default steps somehow fail. If activated (usually by a hardware switch), the
first mechanism checks a GPIO pin if it is high and if yes, the uboot command
in the `UBOOT_FAILSAFE_COMMAND` variable is executed during boot
instead. The default config contains three examples for this command: the first
loads and executes a failsafe.scr script instead of the normal boot.scr from
the first SD card/eMMC partition (see `update-uboot` how such a script is
generated). The second command would start the second boot entry and the third
command would start the builtin uboot script that looks for executable kernels
on a set of devices.

The second mechanism is activated by enabling the `UBOOT_FAILSAFE_FILE` config
setting. If `UBOOT_FAILSAFE_FILE` is set, uboot-manager will write a file with
the given name to the boot partition. If the file does not already exist,
normal boot procedure continues. If the file exists, the chosen
`UBOOT_FAILSAFE_COMMAND` will be executed instead. If you want to use this
mechanism, make sure the operating system will remove the file after a
successful boot. For example, you could put `rm /boot/boot-failure-check`
into `/etc/rc.local`.

Default configuration
---------------------

/etc/uboot.cfg:

	### configure on which devices the u-boot output is shown
	### e.g., to enable HDMI output also for non-error messages, add ",lcd" below
	# UBOOT_STDOUT=serial

	### set this to load a specific device tree binary (dtb)
	# UBOOT_DEVICE_TREE=

	### default entry in the menu. Entries are enumerated as "bootX" where X is the
	### X-th entry in the menu. Default is "boot0", i.e. the first entry
	# UBOOT_DEFAULT=boot0

	### timeout after which the default entry will be booted
	# UBOOT_MENU_TIMEOUT=2

	### default kernel arguments. If a file /boot/cmdline-${kernel_version} exists,
	### its content overrides the default arguments
	# UBOOT_KERNEL_ARGS="rootfstype=btrfs console=ttyAMA0,115200 console=tty1 selinux=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop quiet splash logo.nologo"

	### if set to 1, prepend the default kernel arguments with the kernel arguments
	### set in the device tree
	# UBOOT_PREPEND_FW_KERNEL_ARGS=1

	### partition with the root filesystem (will be passed to the kernel)
	### default is the second partition on the first SD/eMMC device
	# UBOOT_ROOT_PART=/dev/mmcblk0p2

	### if GPIO pin 21 is high, execute UBOOT_FAILSAFE_COMMAND. 
	# UBOOT_FAILSAFE_GPIO_PIN=21

	### If set, this file should be removed by the booted operating system. If this
	### file is still present during the next boot, u-boot will execute
	### UBOOT_FAILSAFE_COMMAND.
	# UBOOT_FAILSAFE_FILE=boot-failure-check

	### run script failsafe.scr (see update-uboot how to generate such a script)
	# UBOOT_FAILSAFE_COMMAND="fatload mmc 0:1 0x02050000 failsafe.scr; source 0x02050000"

	### run the second kernel in the menu
	# UBOOT_FAILSAFE_COMMAND="run boot1"

	### look for and execute a boot script on ${target}, where target can be:
	### dhcp, mmc0, pxe or usb0
	# UBOOT_FAILSAFE_COMMAND="run bootcmd_${target}"

	### Please note, if UBOOT_FAILSAFE_COMMAND command does return, normal boot
	### procedure resumes.
	



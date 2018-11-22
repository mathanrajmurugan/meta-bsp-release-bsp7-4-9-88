# Copyright (C) 2012-2015 O.S. Systems Software LTDA.
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Seco kernel based on the FSL BSP Linux"
DESCRIPTION = "Seco kernel provided support for all Released Secoboards."

require recipes-kernel/linux/linux-imx.inc
#require recipes-kernel/linux/linux-dtb.inc

PV = "4.9"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SCMVERSION = "n"
SRC_URI = "git://secogit.seco.com/imx6_release/linux-4-9-secoboards-imx6-rel.git;user=user:password;protocol=https \
file://defconfig_original \
file://defconfig"



SRCREV = "${AUTOREV}"


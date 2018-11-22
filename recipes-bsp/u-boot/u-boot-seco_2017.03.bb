require recipes-bsp/u-boot/u-boot.inc

# This revision corresponds to the tag "v2017.03"
# We use the revision in order to avoid having to fetch it from the repo during parse

PV = "2017.03"

#FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

# Copyright (C) 2018 Seco SPA 
DESCRIPTION = "U-Boot provided by SECO for secoboards."
PROVIDES = "u-boot"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SCMVERSION = "n"
SRC_URI = "git://secogit.seco.com/imx6_release/u-boot-2017-03-secoboards-imx6-rel.git;user=user:password;protocol=https"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"


do_compile_prepend() {
        if [ "${MACHINE}" = "seco-b08" ]
          then
	    ./compile_b08.sh
 	    install -d ${DEPLOYDIR}
	    install -m 644 u-boot.imx   ${DEPLOYDIR}/
	    install -m 644 u-boot.spi   ${DEPLOYDIR}/
	    install -m 644 uEnv_b08.txt ${DEPLOYDIR}/
	fi
}

inherit fsl-u-boot-localversion

BOOT_TOOLS = "imx-boot-tools"

LOCALVERSION ?= "-${SRCBRANCH}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
#COMPATIBLE_MACHINE = "(seco_928_quad_1gb)"

#UBOOT_MACHINE = "mx6dl_seco_config"
#UBOOT_MAKE_TARGET = "DDR_SIZE=2 DDR_TYPE=1 BOARD_TYPE=A62 CPU_TYPE=DUAL_LITE ENV_DEVICE=ENV_MMC "


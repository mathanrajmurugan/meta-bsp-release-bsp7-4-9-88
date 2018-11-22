#!/bin/bash

type_uQseven="imx6-962"
type_A62="imx6"

type_cpu_qdl="Q/D/DL/S"
CONFIG_FILE=".yocto-seco-config"

env_MMC="MMC"
env_SATA="SATA"
env_SPI="SPI"

BACKTITLE='Yocto SECO config'

PATH_MACHINE="sources/meta-seco-bsp-release-bsp7-rel/conf/machine/"

SELECTION=""
SEL_ITEM=1
SELECTION_COMP=""
SUBSEL=""
EXIT_RESPONCE=0
EXIT=0

# Default values
MEM_SIZE=1
BOARD=${type_uQseven}
CPU_TYPE=${type_cpu_qdl}
ENV_DEV=${env_MMC}
COMPILER_PATH="/opt/fsl-imx-x11/4.9.88-2.0.0/environment-setup-cortexa9hf-neon-poky-linux-gnueabi"
UBOOT_BOARD_CONF="mx6qdl_seco_uQ7_962_2G_1G_2x256M_defconfig"
DTB_CONF="imx6q-seco_uq7_962.dtb imx6dl-seco_uq7_962.dtb"
SOC_FAMILY="mx6:mx6dl:mx6q:"

# Yocto variable
# BACKEND
BACKEND_X11="seco-imx-x11"
BACKEND_FB="seco-imx-fb"
BACKEND_XWAYLAND="seco-imx-xwayland"
BACKEND_WAYLAND="seco-imx-wayland"

# COMPILATION IMAGE 
IMAGE_SECO_CORE_IMAGE_MINIMAL="seco-core-image-minimal"
IMAGE_SECO_CORE_IMAGE_BASE="seco-core-image-base"
IMAGE_SECO_CORE_IMAGE_SATO="seco-core-image-sato"
IMAGE_SECO_IMAGE_MACHINE_TEST="seco-image-machine-test"
IMAGE_SECO_IMAGE_GUI="seco-image-gui"
IMAGE_SECO_IMAGE_QT5="seco-image-qt5"

#################################################################
#																#
#					CONFIG FILE FUNCTION						#
#																#
#################################################################

set_ConfFile() {
	echo "MEMORY_SIZE $MEM_SIZE" > $CONFIG_FILE
	echo "BOARD_TYPE $BOARD" >> $CONFIG_FILE
	echo "CPU_TYPE $CPU_TYPE" >> $CONFIG_FILE
	echo "ENV_DEVICE $ENV_DEV" >> $CONFIG_FILE
	echo "BACKEND $BACKEND" >> $CONFIG_FILE
	echo "IMAGE_TYPE $IMAGE_TYPE" >> $CONFIG_FILE
}

set_from_ConfFile() {

	if [[ -e $CONFIG_FILE ]]; then
		VAR=$(cat $CONFIG_FILE | grep "MEMORY_SIZE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			MEM_SIZE=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "BOARD_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			BOARD=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "CPU_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			CPU_TYPE=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "ENV_DEVICE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			ENV_DEV=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "BACKEND" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        BACKEND=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "IMAGE_TYPE" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        IMAGE_TYPE=$VAR
                fi
	else
		echo "WARNING: Configuration file not found!"
		set_ConfFile
	fi
}


#################################################################
#																#
#						GRAPHIC FUNCTION						#
#																#
#################################################################


main_view() {
	# open fd
	exec 3>&1
	 
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Seco Yocto Main Menu" \
			--backtitle "$BACKTITLE" \
			--ok-label "Select" \
			--default-item $SEL_ITEM \
			--cancel-label "Exit" \
			--menu "Please choose an operation:" 25 60 10 \
			1 "DDR Size  -->" \
			2 "Board Type -->" \
			3 "CPU type -->" \
			4 "Environment device -->" \
			5 "yocto backend options -->" \
			6 "yocto image type -->" \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		EXIT=1
 	fi
	# display values just entered
#	echo "$SELECTION"
	
}

ddr_size_view() {
	# open fd
	exec 3>&1
	VAL=(off)
	VAL[$MEM_SIZE]=on
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "DDR configuration" \
			--backtitle "$BACKTITLE" \
			--ok-label "Select" \
			--cancel-label "Exit" \
			--default-item $MEM_SIZE \
			--radiolist "Select DDR type:" 20 80 10 \
			0 "2G/1G/2x256M,  bus size 32, active CS = 1 (2G/1G/2x256M)" ${VAL[0]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		MEM_SIZE=$SELECTION
	fi	
}

board_type_view() {
	# open fd
	exec 3>&1
	VAL=(off off)
	case "$BOARD" in
		   	"$type_uQseven") VAL[0]=on;;
			"$type_A62") VAL[1]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Board type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--default-item $BOARD \
			--radiolist "Select Board type:" 20 60 10 \
			$type_uQseven "Micro Qseven board" ${VAL[0]} \
			$type_A62 "A62 Single board" ${VAL[1]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		BOARD=$SELECTION
	fi	
}

cpu_type_view() {
	# open fd
	exec 3>&1
	VAL=(off)
	case "$CPU_TYPE" in
			"$type_cpu_qdl") VAL[0]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "CPU type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--radiolist "Select CPU type:" 20 60 10 \
			$type_cpu_qdl "iMX6 QUAD/DL/S" ${VAL[0]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		CPU_TYPE=$SELECTION
	fi	
}

env_dev_view() {
	# open fd
	exec 3>&1
	VAL=(off off off)
	case "$ENV_DEV" in
		 "${env_MMC}") VAL[0]=on;; 
		"${env_SATA}") VAL[1]=on;;
		 "${env_SPI}") VAL[2]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Environment device" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--default-item $ENV_DEV \
			--radiolist "Select device for environmnet storing:" 20 60 10 \
			$env_MMC "SD/MMC as environment device"  ${VAL[0]} \
 			$env_SATA "SATA as environment device"  ${VAL[1]} \
			$env_SPI "SPI as enviroment device"  ${VAL[2]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		ENV_DEV=$SELECTION
	fi	
}

yocto_backend_view() {
	# open fd
        exec 3>&1
        VAL=(off off off off)
        case "$BACKEND" in
                 "${BACKEND_X11}") VAL[0]=on;;
                "${BACKEND_FB}") VAL[1]=on;;
                 "${BACKEND_DFB}") VAL[2]=on;;
		"${BACKEND_WAYLAND}") VAL[3]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --default-item $ENV_DEV \
                        --radiolist "Select backend for graphics:" 20 60 10 \
                        $BACKEND_X11 "Xorg X11 as backend"  ${VAL[0]} \
                        $BACKEND_FB "Framebuffer as backend"  ${VAL[1]} \
                        $BACKEND_XWAYLAND "xWayland as backend"  ${VAL[2]} \
			$BACKEND_WAYLAND "Wayland as backend"  ${VAL[3]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                BACKEND=$SELECTION
        fi


}

yocto_image_type_view() {
        # open fd
        exec 3>&1
        VAL=(off off off off off off)
        case "$IMAGE_TYPE" in
                 "${IMAGE_SECO_CORE_IMAGE_MINIMAL}") VAL[0]=on;;
                "${IMAGE_SECO_CORE_IMAGE_BASE}") VAL[1]=on;;
                 "${IMAGE_SECO_CORE_IMAGE_SATO}") VAL[2]=on;;
                "${IMAGE_SECO_IMAGE_MACHINE_TEST}") VAL[3]=on;;
		 "${IMAGE_SECO_IMAGE_GUI}") VAL[4]=on;;
		 "${IMAGE_SECO_IMAGE_QT5}") VAL[5]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --default-item $ENV_DEV \
                        --radiolist "Select backend for graphics:" 20 100 40 \
                        $IMAGE_SECO_CORE_IMAGE_MINIMAL "only allows a device to boot."  ${VAL[0]} \
                        $IMAGE_SECO_CORE_IMAGE_BASE "A console-only image"  ${VAL[1]} \
                        $IMAGE_SECO_CORE_IMAGE_SATO "This image supports X11 with a Sato theme, Pimlico applications"  ${VAL[2]} \
			$IMAGE_SECO_IMAGE_MACHINE_TEST "An FSL Community i.MX core image with console environment, no GUI"  ${VAL[3]} \
                        $IMAGE_SECO_IMAGE_GUI "This image is for X11, xwayland, Frame Buffer and Wayland"  ${VAL[4]} \
			$IMAGE_SECO_IMAGE_QT5 "Builds a QT5 image for X11, Frame Buffer and Wayland backends"  ${VAL[5]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                IMAGE_TYPE=$SELECTION
        fi
}


#################################################################
#																#
#						COMPILE FUNCTION						#
#																#
#################################################################

function check_mem_size () {
	echo ""
	if [ "${MEM_SIZE}" == "0" ]; then
		echo "RAM size selected: 2G/1G/2x256M,  bus size 32, active CS = 1 (2G/1G/2x256M)"
		#SUFFIX=${SUFFIX}-2G/1G/2x256M
	else
		echo "ERROR: wrong DDR size selected"
		exit 0
	fi
}

function check_board_type () {
	echo ""
	if [ "${BOARD}" == "${type_uQseven}" ]; then
		echo "Board type selected: micro Qseven module"
		#SUFFIX=${SUFFIX}-seco-imx6
	elif [ "${BOARD}" == "${type_A62}" ]; then
                echo "Board type selected: A62 Single Board"
                #SUFFIX=${SUFFIX}-seco-imx6
	else
		echo "ERROR: wrong board type selected"
		exit 0
	fi
}

function check_cpu_type () {
	echo ""
    if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
        #echo "make mx6q_seco_config"
		#SUFFIX=${SUFFIX}-QD
		SOC_FAMILY="mx6:mx6dl:mx6q:"
	else
		echo "ERROR: No CPU Type selected "
	fi
}
		
function check_env_device_type () {
	echo ""
	if [ "${ENV_DEV}" == "${env_MMC}" ]; then
		echo "Environment selected: MMC"
	elif [ "${ENV_DEV}" == "${env_SATA}" ]; then
		echo "Environment selected: SATA"
	elif [ "${ENV_DEV}" == "${env_SPI}" ]; then
		echo "Environment selected: SPI"
	else
		echo "ERROR: wrong environment selected"
		exit 0
	fi
}

function conf_cpu_type () {
	echo ""
        if [ "${BOARD}" == "${type_uQseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                UBOOT_BOARD_CONF="mx6qdl_seco_uQ7_962_2G_1G_2x256M_defconfig"
            fi
        elif [ "${BOARD}" == "${type_A62}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                UBOOT_BOARD_CONF="mx6qdl_seco_SBC_A62_1G_2x256M_defconfig"
            fi
        fi
}

function check_dtb () {

	echo ""
        if [ "${BOARD}" == "${type_uQseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                DTB_CONF="imx6q-seco_uq7_962.dtb imx6dl-seco_uq7_962.dtb"
            fi
        elif [ "${BOARD}" == "${type_A62}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                DTB_CONF="imx6q-seco_SBC_A62.dtb imx6dl-seco_SBC_A62.dtb"
            fi
        fi

}

function create_machine() {

 export ARCH=arm
        export CROSS_COMPILE=$COMPILER_PATH

        #SUFFIX=""
        #N.B. don't change this calling order
        check_board_type
        check_cpu_type
	conf_cpu_type
        check_mem_size
        check_env_device_type
	check_dtb

MACHINE_CONF_NAME=`echo "seco-${BOARD}.conf" | tr '[:upper:]' '[:lower:]'`
MACHINE_NAME=`echo "seco-${BOARD}" | tr '[:upper:]' '[:lower:]'`

#echo $MACHINE_NAME
echo ""
echo "#@TYPE: Machine" > $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@NAME: seco-imx6" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@SOC: i.MX6${CPU_TYPE}" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@DESCRIPTION: Machine configuration for SECO $BOARD"  >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "MACHINEOVERRIDES =. \"${SOC_FAMILY}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/imx-base.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/tune-cortexa9.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_u-boot = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_u-boot_mx6 = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/bootloader = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/bootloader_mx6 = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_MAKE_TARGET = \" \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_SUFFIX= \"img\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "SPL_BINARY = \"SPL\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_MACHINE = \"${UBOOT_BOARD_CONF} \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/kernel ?= \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/kernel_mx6 = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "KERNEL_DEVICETREE ?= \"${DTB_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "KERNEL_IMAGETYPE = \"zImage\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "SERIAL_CONSOLE = \"115200 ttymxc1\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME



echo "To begin yocto building launch :"
echo "$ MACHINE=$MACHINE_NAME DISTRO=$BACKEND source seco-setup-release.sh -b <build dir>"
echo ""
echo ""
echo "and then launch:"
echo "$ bitbake $IMAGE_TYPE"

}


#################################################################
#																#
#																#
#################################################################

function help_view () {
	echo "SECO Yocto Configurator"
	echo "Usage: $0 [-c for configuration option]"
	echo
}

set_from_ConfFile
while getopts ":m:b:p:dch" optname; do
	case "$optname" in
		"c") while [[ $EXIT -ne 1 ]]; do
			main_view
			SEL_ITEM=$SELECTION
			case "$SELECTION" in
				"1") ddr_size_view;;
				"2") board_type_view;;
				"3") cpu_type_view;;
				"4") env_dev_view;;
				"5") yocto_backend_view;;
				"6") yocto_image_type_view;;
				  *) echo "" ;;
			esac
		done
		#exit_view
		case "${EXIT_RESPONCE}" in
			  "0") set_ConfFile; clear; echo "Configuration saved!"; create_machine;;
			  "1") clear; echo "Configuration not saved!";;
			  "3") set_ConfFile; clear; echo "Configuration saved!"; compile;;
			"255") clear;  echo "Configuration not saved!";;
			*) clear;
		esac
		exit 0;;

		h) help_view
			 exit 0;;	
		*) echo "ERROR: option not valid!"
                         help_view
                         exit 1;;
	esac
done

#if no any option is present, the compilation start directly
compile


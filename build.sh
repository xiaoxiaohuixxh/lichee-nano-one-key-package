
#!/bin/bash

echo "Welcome to use lichee pi one key package"
toolchain_dir="toolchain"
cross_compiler="arm-linux-gnueabi"
temp_root_dir=$PWD

#uboot=========================================================
u_boot_dir="Lichee-Pi-u-boot"
u_boot_config_file=""
u_boot_boot_cmd_file=""
#uboot=========================================================

#linux opt=========================================================
linux_dir="Lichee-Pi-linux"
linux_config_file=""
#linux opt=========================================================

#linux opt=========================================================
buildroot_dir="buildroot-2017.08"
buildroot_config_file=""
#linux opt=========================================================

#pull===================================================================
pull_uboot(){
	rm -rf ${temp_root_dir}/${u_boot_dir} &&\
	mkdir -p ${temp_root_dir}/${u_boot_dir} &&\
	cd ${temp_root_dir}/${u_boot_dir} &&\
	git clone -b nano-v2018.01 https://github.com/Lichee-Pi/u-boot.git
	if [ ! -d ${temp_root_dir}/${u_boot_dir}/u-boot ]; then
		echo "Error:pull u_boot failed"
    		exit 0
	else	
		mv ${temp_root_dir}/${u_boot_dir}/u-boot/* ${temp_root_dir}/${u_boot_dir}/	
		rm -rf ${temp_root_dir}/${u_boot_dir}/u-boot	
		echo "pull buildroot ok"
	fi
}
pull_linux(){
	rm -rf ${temp_root_dir}/${linux_dir} &&\
	mkdir -p ${temp_root_dir}/${linux_dir} &&\
	cd ${temp_root_dir}/${linux_dir} &&\
	#git clone --depth=1 -b nano-4.14-exp https://github.com/Lichee-Pi/linux.git
	git clone -b f1c100s --depth=1 https://github.com/Icenowy/linux.git
	if [ ! -d ${temp_root_dir}/${linux_dir}/linux ]; then
		echo "Error:pull linux failed"
    		exit 0
	else	
		mv ${temp_root_dir}/${linux_dir}/linux/* ${temp_root_dir}/${linux_dir}/
		rm -rf ${temp_root_dir}/${linux_dir}/linux
		echo "pull buildroot ok"
	fi
}
pull_toolchain(){
	rm -rf ${temp_root_dir}/${toolchain_dir}
	mkdir -p ${temp_root_dir}/${toolchain_dir}
	cd ${temp_root_dir}/${toolchain_dir}
	ldconfig
	if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
		wget http://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabi/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi.tar.xz &&\
		tar xvJf gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi.tar.xz
		if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi ]; then
			echo "Error:pull toolchain failed"
	    		exit 0
		else			
			echo "pull buildroot ok"
		fi
	else
	 	wget http://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabi/gcc-linaro-7.4.1-2019.02-i686_arm-linux-gnueabi.tar.xz &&\
		tar xvJf gcc-linaro-7.4.1-2019.02-i686_arm-linux-gnueabi.tar.xz
		if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-i686_arm-linux-gnueabi ]; then
			echo "Error:pull toolchain failed"
	    		exit 0
		else			
			echo "pull buildroot ok"
		fi
	fi
}
pull_buildroot(){
	rm -rf ${temp_root_dir}/${buildroot_dir}
	mkdir -p ${temp_root_dir}/${buildroot_dir}
	cd ${temp_root_dir}/${buildroot_dir}  &&\
	wget https://buildroot.org/downloads/buildroot-2017.08.tar.gz &&\
	tar xvf buildroot-2017.08.tar.gz
	if [ ! -d ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08 ]; then
		echo "Error:pull buildroot failed"
    		exit 0
	else			
		# mv ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/* ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08
		# rm -rf ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08
		echo "pull buildroot ok"
	fi
}
pull_all(){
        sudo apt-get update
	sudo apt-get install -y autoconf automake libtool gettext 
        sudo apt-get install -y make gcc g++ swig python-dev bc python u-boot-tools bison flex bc libssl-dev libncurses5-dev unzip mtd-utils
	sudo apt-get install -y libc6-i386 lib32stdc++6 lib32z1
	sudo apt-get install -y libc6:i386 libstdc++6:i386 zlib1g:i386
	pull_uboot
	pull_linux
	pull_toolchain
	pull_buildroot
	cp -f ${temp_root_dir}/buildroot.config ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08
	cp -f ${temp_root_dir}/linux-licheepi_nano_defconfig ${temp_root_dir}/${linux_dir}/arch/arm/configs/licheepi_nano_defconfig
	cp -f ${temp_root_dir}/linux-licheepi_nano_spiflash_defconfig ${temp_root_dir}/${linux_dir}/arch/arm/configs/licheepi_nano_spiflash_defconfig
	cp -f ${temp_root_dir}/linux-suniv-f1c100s-licheepi-nano-with-lcd.dts ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/suniv-f1c100s-licheepi-nano-with-lcd.dts
	cp -f ${temp_root_dir}/uboot-licheepi_nano_defconfig ${temp_root_dir}/${u_boot_dir}/configs/licheepi_nano_defconfig
	cp -f ${temp_root_dir}/uboot-licheepi_nano_spiflash_defconfig ${temp_root_dir}/${u_boot_dir}/configs/licheepi_nano_spiflash_defconfig
	mkdir -p ${temp_root_dir}/output

}
#pull===================================================================

#env===================================================================
update_env(){
	if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-i686_arm-linux-gnueabi ]; then
		if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi ]; then
			echo "Error:toolchain not found,Please use ./build.sh pull_all "
	    		exit 0
		else			
			export PATH="$PWD/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin":"$PATH"
		fi
	else
		export PATH="$PWD/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-i686_arm-linux-gnueabi/bin":"$PATH"
	fi
	
}
check_env(){
	if [ ! -d ${temp_root_dir}/${toolchain_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${u_boot_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${buildroot_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${linux_dir} ]; then
		echo "Error:env error,Please use ./build.sh pull_all"
		exit 0
	fi
}
#env===================================================================

#clean===================================================================
clean_log(){
	rm -f ${temp_root_dir}/*.log
}

clean_all(){
	clean_log
	clean_uboot
	clean_linux
	clean_buildroot
}
#clean===================================================================


#uboot=========================================================

clean_uboot(){
	cd ${temp_root_dir}/${u_boot_dir}
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- mrproper > /dev/null 2>&1
}


build_uboot(){
	cd ${temp_root_dir}/${u_boot_dir}
	echo "Building uboot ..."
    	echo "--->Configuring ..."
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${u_boot_config_file} > /dev/null 2>&1
        # cp -f ${temp_root_dir}/${u_boot_config_file} ${temp_root_dir}/${u_boot_dir}/.config
	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${u_boot_dir}/.config ]; then
		echo "Error: .config file not exist"
		exit 1
	fi
	echo "--->Get cpu info ..."
	proc_processor=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
	echo "--->Compiling ..."
  	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} > ${temp_root_dir}/build_uboot.log 2>&1

	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${u_boot_dir}/u-boot ]; then
        	echo "Error: UBOOT NOT BUILD.Please Get Some Error From build_uboot.log"
		error_msg=$(cat ${temp_root_dir}/build_uboot.log)
		if [[ $(echo $error_msg | grep "ImportError: No module named _libfdt") != "" ]];then
		    echo "Please use Python2.7 as default python interpreter"
		fi
        	exit 1
	fi

	if [ ! -f ${temp_root_dir}/${u_boot_dir}/u-boot-sunxi-with-spl.bin ]; then
        	echo "Error: UBOOT NOT BUILD.Please Enable spl option"
        	exit 1
	fi
	#make boot.src
	if [ -n "$u_boot_boot_cmd_file" ];then
		mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Beagleboard boot script" -d ${temp_root_dir}/${u_boot_boot_cmd_file} ${temp_root_dir}/output/boot.scr
	fi
	echo "Build uboot ok"
}
#uboot=========================================================

#linux=========================================================

clean_linux(){
	cd ${temp_root_dir}/${linux_dir}
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- mrproper > /dev/null 2>&1
}


build_linux(){
	cd ${temp_root_dir}/${linux_dir}
	echo "Building linux ..."
    	echo "--->Configuring ..."
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${linux_config_file} > /dev/null 2>&1
	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${linux_dir}/.config ]; then
		echo "Error: .config file not exist"
		exit 1
	fi
	echo "--->Get cpu info ..."
	proc_processor=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
	echo "--->Compiling ..."
  	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} > ${temp_root_dir}/build_linux.log 2>&1

	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${linux_dir}/arch/arm/boot/zImage ]; then
        	echo "Error: LINUX NOT BUILD.Please Get Some Error From build_linux.log"
		#error_msg=$(cat ${temp_root_dir}/build_linux.log)
		#if [[ $(echo $error_msg | grep "ImportError: No module named _libfdt") != "" ]];then
		#    echo "Please use Python2.7 as default python interpreter"
		#fi
        	exit 1
	fi

	if [ ! -f ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/suniv-f1c100s-licheepi-nano-with-lcd.dtb ]; then
        	echo "Error: UBOOT NOT BUILD.${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/suniv-f1c100s-licheepi-nano-with-lcd.dtb not found"
        	exit 1
	fi
	#build linux kernel modules
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} INSTALL_MOD_PATH=${temp_root_dir}/${linux_dir}/mod_output modules > /dev/null 2>&1
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} INSTALL_MOD_PATH=${temp_root_dir}/${linux_dir}/mod_output modules_install > /dev/null 2>&1
	
	echo "Build linux ok"
}
#linux=========================================================

#linux=========================================================

clean_buildroot(){
	cd ${temp_root_dir}/${buildroot_dir}
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- clean > /dev/null 2>&1
}


build_buildroot(){
	cd ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08
	echo "Building buildroot ..."
    	echo "--->Configuring ..."
	rm ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/.config
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- defconfig
	cp -f ${temp_root_dir}/buildroot.config ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/.config
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/.config
	# make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${buildroot_config_file} > /dev/null 2>&1
	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/.config ]; then
		echo "Error: .config file not exist"
		exit 1
	fi
	echo "--->Compiling ..."
  	make ARCH=arm CROSS_COMPILE=${cross_compiler}- > ${temp_root_dir}/build_buildroot.log 2>&1

	if [ $? -ne 0 ] || [ ! -d ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/output/target ]; then
        	echo "Error: BUILDROOT NOT BUILD.Please Get Some Error From build_buildroot.log"
        	exit 1
	fi
	echo "Build buildroot ok"
}
#linux=========================================================

#copy=========================================================
copy_uboot(){
	cp ${temp_root_dir}/${u_boot_dir}/u-boot-sunxi-with-spl.bin ${temp_root_dir}/output/
}
copy_linux(){
	cp ${temp_root_dir}/${linux_dir}/arch/arm/boot/zImage ${temp_root_dir}/output/
	cp ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/suniv-f1c100s-licheepi-nano-with-lcd.dtb ${temp_root_dir}/output/
	mkdir -p ${temp_root_dir}/output/modules/
	cp -rf ${temp_root_dir}/${linux_dir}/mod_output/lib ${temp_root_dir}/output/modules/
	
}
copy_buildroot(){
	cp -r ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/output/target ${temp_root_dir}/output/rootfs/
	cp ${temp_root_dir}/${buildroot_dir}/buildroot-2017.08/output/images/rootfs.tar ${temp_root_dir}/output/
	gzip -c ${temp_root_dir}/output/rootfs.tar > ${temp_root_dir}/output/rootfs.tar.gz
}
#copy=========================================================

#pack=========================================================
pack_spiflash_normal_size_img(){

	mkdir -p ${temp_root_dir}/output/spiflash-bin
	dd if=/dev/zero of=${temp_root_dir}/output/spiflash-bin/lichee-nano-normal-size.bin bs=1M count=16
	echo "--->Packing Uboot..."
	_UBOOT_FILE=${temp_root_dir}/output/u-boot-sunxi-with-spl.bin
	dd if=$_UBOOT_FILE of=${temp_root_dir}/output/spiflash-bin/lichee-nano-normal-size.bin bs=1K conv=notrunc
	_DTB_FILE=${temp_root_dir}/output/suniv-f1c100s-licheepi-nano-with-lcd.dtb
	echo "--->Packing dtb..."
	dd if=$_DTB_FILE of=${temp_root_dir}/output/spiflash-bin/lichee-nano-normal-size.bin bs=1K seek=1024  conv=notrunc
	echo "--->Packing zImage..."
	_KERNEL_FILE=${temp_root_dir}/output/zImage
	dd if=$_KERNEL_FILE of=${temp_root_dir}/output/spiflash-bin/lichee-nano-normal-size.bin bs=1K seek=1088  conv=notrunc
	echo "--->Packing rootfs..."
	#cp -r $_MOD_FILE  ${temp_root_dir}/output/rootfs/lib/modules/
	mkfs.jffs2 -s 0x100 -e 0x10000 --pad=0xAF0000 -d ${temp_root_dir}/output/rootfs/ -o ${temp_root_dir}/output/jffs2.img
	dd if=${temp_root_dir}/output/jffs2.img of=${temp_root_dir}/output/spiflash-bin/lichee-nano-normal-size.bin  bs=1K seek=5184  conv=notrunc
	echo "pack ok"
}
pack_tf_normal_size_img(){
	_ROOTFS_FILE=${temp_root_dir}/output/rootfs.tar.gz
	_ROOTFS_SIZE=`gzip -l $_ROOTFS_FILE | sed -n '2p' | awk '{print $2}'`
	_ROOTFS_SIZE=`echo "scale=3;$_ROOTFS_SIZE/1024/1024" | bc`

	_UBOOT_SIZE=1
	_CFG_SIZEKB=0
	_P1_SIZE=16
	_IMG_SIZE=200
	_kernel_mod_dir_name=$(ls ${temp_root_dir}/output/modules/lib/modules/)
	_MOD_FILE=${temp_root_dir}/output/modules/lib/modules/${_kernel_mod_dir_name}
	_MOD_SIZE=`du $_MOD_FILE --max-depth=0 | cut -f 1`
	_MOD_SIZE=`echo "scale=3;$_MOD_SIZE/1024" | bc`
	_MIN_SIZE=`echo "scale=3;$_UBOOT_SIZE+$_P1_SIZE+$_ROOTFS_SIZE+$_MOD_SIZE+$_CFG_SIZEKB/1024" | bc` #+$_OVERLAY_SIZE
	_MIN_SIZE=$(echo "$_MIN_SIZE" | bc)
	echo  "--->min img size = $_MIN_SIZE MB"
	_MIN_SIZE=$(echo "${_MIN_SIZE%.*}+1"|bc)

	_FREE_SIZE=`echo "$_IMG_SIZE-$_MIN_SIZE"|bc`
	_IMG_FILE=${temp_root_dir}/output/image/lichee-nano-normal-size.img
	mkdir -p ${temp_root_dir}/output/image
	rm $_IMG_FILE
	dd if=/dev/zero of=$_IMG_FILE bs=1M count=$_IMG_SIZE
	if [ $? -ne 0 ]
	then 
		echo  "getting error in creating dd img!"
	    	exit
	fi
	_LOOP_DEV=$(sudo losetup -f)
	if [ -z $_LOOP_DEV ]
	then 
		echo  "can not find a loop device!"
		exit
	fi
	sudo losetup $_LOOP_DEV $_IMG_FILE
	if [ $? -ne 0 ]
	then 
		echo  "dd img --> $_LOOP_DEV error!"
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
	fi
	echo  "--->creating partitions for tf image ..."
	#blockdev --rereadpt $_LOOP_DEV >/dev/null 2>&1
	# size only can be integer
	cat <<EOT |sudo  sfdisk $_IMG_FILE
${_UBOOT_SIZE}M,${_P1_SIZE}M,c
,,L
EOT

	sleep 2
	sudo partx -u $_LOOP_DEV
	sudo mkfs.vfat ${_LOOP_DEV}p1 ||exit
	sudo mkfs.ext4 ${_LOOP_DEV}p2 ||exit
	if [ $? -ne 0 ]
	then 
		echo  "error in creating partitions"
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
		#sudo partprobe $_LOOP_DEV >/dev/null 2>&1 && exit
	fi

	#pack uboot
	echo  "--->writing u-boot-sunxi-with-spl to $_LOOP_DEV"
	# sudo dd if=/dev/zero of=$_LOOP_DEV bs=1K seek=1 count=1023  # clear except mbr
	_UBOOT_FILE=${temp_root_dir}/output/u-boot-sunxi-with-spl.bin
	sudo dd if=$_UBOOT_FILE of=$_LOOP_DEV bs=1024 seek=8
	if [ $? -ne 0 ]
	then 
		echo  "writing u-boot error!"
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
		#sudo partprobe $_LOOP_DEV >/dev/null 2>&1 && exit
	fi

	sudo sync
	mkdir -p ${temp_root_dir}/output/p1 >/dev/null 2>&1
	mkdir -p ${temp_root_dir}/output/p2 > /dev/null 2>&1
	sudo mount ${_LOOP_DEV}p1 ${temp_root_dir}/output/p1
	sudo mount ${_LOOP_DEV}p2 ${temp_root_dir}/output/p2
	echo  "--->copy boot and rootfs files..."
	sudo rm -rf  ${temp_root_dir}/output/p1/* && sudo rm -rf ${temp_root_dir}/output/p2/*

	#pack linux kernel
	_KERNEL_FILE=${temp_root_dir}/output/zImage
	_DTB_FILE=${temp_root_dir}/output/suniv-f1c100s-licheepi-nano-with-lcd.dtb
	sudo cp $_KERNEL_FILE ${temp_root_dir}/output/p1/zImage &&\
        sudo cp $_DTB_FILE ${temp_root_dir}/output/p1/ &&\
        sudo cp ${temp_root_dir}/output/boot.scr ${temp_root_dir}/output/p1/ &&\
        echo "--->p1 done~"
        sudo tar xzvf $_ROOTFS_FILE -C ${temp_root_dir}/output/p2/ &&\
        echo "--->p2 done~"
        # sudo cp -r $_OVERLAY_BASE/*  p2/ &&\
        # sudo cp -r $_OVERLAY_FILE/*  p2/ &&\
        sudo mkdir -p ${temp_root_dir}/output/p2/lib/modules/${_kernel_mod_dir_name}/ &&\
        sudo cp -r $_MOD_FILE/*  ${temp_root_dir}/output/p2/lib/modules/${_kernel_mod_dir_name}/
        echo "--->modules done~"
        
        if [ $? -ne 0 ]
        then 
		echo "copy files error! "
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1
		sudo umount ${_LOOP_DEV}p1  ${_LOOP_DEV}p2 >/dev/null 2>&1
		exit
        fi
        echo "--->The tf card image-packing task done~"
	sudo sync
	sleep 2
	sudo umount ${temp_root_dir}/output/p1 ${temp_root_dir}/output/p2  && sudo losetup -d $_LOOP_DEV
	if [ $? -ne 0 ]
	then 
		echo  "umount or losetup -d error!!"
		exit
	fi
}
#pack=========================================================

#clean output dir=========================================================
clean_output_dir(){
	rm -rf ${temp_root_dir}/output/*
}
#clean output dir=========================================================
build(){
	check_env
	update_env
	echo "clean log ..."
	clean_log
	echo "clean output dir ..."
	clean_output_dir
	build_uboot
	echo "copy uboot ..."
	copy_uboot
	build_linux
	echo "copy linux ..."
	copy_linux
	build_buildroot
	echo "copy buildroot ..."
	copy_buildroot
	
	
}
if [ "${1}" = "" ] && [ ! "${1}" = "nano_spiflash" ] && [ ! "${1}" = "nano_tf" ] && [ ! "${1}" = "pull_all" ]; then
	echo "Usage: build.sh [nano_spiflash | nano_tf | pull_all | clean]"；
	echo "One key build nano finware";
	echo " ";
	echo "nano_spiflash    Build nano firmware booted from spiflash";
	echo "nano_tf          Build nano firmware booted from tf";
	echo "pull_all         Pull build env from internet";
	echo "clean            Clean build env";
    exit 0
fi
if [ ! -f ${temp_root_dir}/build.sh ]; then
	echo "Error:Please enter packge root dir"
    	exit 0
fi

if [ "${1}" = "clean" ]; then
	clean_all
	echo "clean ok"
	exit 0
fi
if [ "${1}" = "pull_all" ]; then
	pull_all
fi
if [ "${1}" = "pull_buildroot" ]; then
	pull_buildroot
fi
if [ "${1}" = "nano_spiflash" ]; then
	echo "build rootfs maybe have some buf in this mode"
	linux_config_file="licheepi_nano_spiflash_defconfig"
	u_boot_config_file="licheepi_nano_spiflash_defconfig"
	build
	pack_spiflash_normal_size_img
	echo "the binary file in output/spiflash-bin dir"
fi
if [ "${1}" = "build_buildroot" ]; then
	build_buildroot
fi
if [ "${1}" = "nano_tf" ]; then
	linux_config_file="licheepi_nano_defconfig"
	u_boot_config_file="licheepi_nano_defconfig"
	u_boot_boot_cmd_file="tf_boot.cmd"
	build
	pack_tf_normal_size_img
	echo "the image file in output/image dir"
fi

sleep 1
echo "build ok"


#-------------------------------------------------------------------------------------------------------------------------
# Description	: Setup file for installing SDK for the Quick Logic EOS-S3 board (for Raspberry Pi OS based systems).
# Author		: Farhan Rasheed
# Email			: frasheed.dev@gmail.com
# GitHub		: https://github.com/frasheed-dev/
#-------------------------------------------------------------------------------------------------------------------------

# BASIC INFORMATION
# -----------------

# QORC SDK
# ========
# QuickLogic Open Reconfigurable Computing (QORC) SDK provides components
# needed to get started on the QuickLogic's EOS-S3 device and open source
# development boards such as Quickfeather.
# Further Details:
# [1] Github: https://github.com/QuickLogic-Corp/qorc-sdk
# [2] Documentation: https://qorc-sdk.readthedocs.io/en/latest/index.html

# Supportted Boards
# =================
# As of August 2022, following hardware boards are supported:
#-  `SparkFun Thing Plus (Board used in this work) <https://www.quicklogic.com/products/eos-s3/sparkfun-thing-plus/>`__
#-  `Quickfeather Development Kit <https://www.quicklogic.com/products/eos-s3/quickfeather-development-kit/>`__
#-  `Qomu Development Kit <https://www.quicklogic.com/products/eos-s3/qomu-dev-kit/>`__

# INSTALLATION
# ------------

# Official Installation Guide: https://qorc-sdk.readthedocs.io/en/latest/qorc-setup/quickstart.html

# Since there is a detailed guide available on how to install the QORC SDK, I will trim it to my usecase for the following Hardware/Software components:
#	Hardware: Raspberry Pi 4 Model B Rev 1.4 (4GB RAM) 
#	Software: Raspberry Pi OS (64-bit)  
#	uname -a: Linux pi4 5.15.32-v8+ #1538 SMP PREEMPT Thu Mar 31 19:40:39 BST 2022 aarch64 GNU/Linux
#	FPGA	: SparkFun Thing Plus (QuickLogic EOS S3)

# setting some variables
export F4PGA_INSTALL_DIR=~/opt/f4pga
export FPGA_FAM=eos-s3

# (2.1) Download architecture definitions (for Quicklogic EOS-S3)
echo "[LOG]: Installing architecture definitions"
wget -qO- https://storage.googleapis.com/symbiflow-arch-defs-install/quicklogic-arch-defs-qlf-fc5d8da.tar.gz | tar -xzC $F4PGA_INSTALL_DIR/$FPGA_FAM/

# (2.2) QORC SDK Submodules
git clone https://github.com/QuickLogic-Corp/qorc-sdk.git
cd qorc-sdk
git submodule update --init qorc-example-apps
git submodule update --init qorc-testapps
git submodule update --init s3-gateware

# (2.3) ARM Cortex M4 Build Toolchain
# I had gcc version 10.2.1 20210110 (Debian 10.2.1-6) so, I installed "10-2020-q4-major" release from:
#- https://developer.arm.com/downloads/-/gnu-rm
wget -O gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 -q --show-progress --progress=bar:force 2>&1 "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2?revision=cff794bc-3fb1-4c9c-934b-782886767324&hash=50FBD97155D0006C0BA3099C44BE064F"
mkdir arm_toolchain_install
tar xvjf gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2  -C ${PWD}/arm_toolchain_install
# temporary add path for current session (for pemenant adding to PATH, copy the next line with complete path to ~/.bashrc or ~/.bash_profile)
export PATH=${PWD}/arm_toolchain_install/gcc-arm-none-eabi-10-2020-q4-major/bin:$PATH

# (2.4) QuickLogic TinyFPGA-Programmer-Application
git clone --recursive https://github.com/QuickLogic-Corp/TinyFPGA-Programmer-Application.git
pip3 install tinyfpgab
pip3 install -U apio
apio drivers --serial-enable
# Restart OS!
# temporary alias set for current session (for permenant alias, add the next line with complete path to ~/.bashrc or ~/.bash_profile)
alias qfprog="python ${PWD}/TinyFPGA-Programmer-Application/tinyfpga-programmer-gui.py"
# test programmer application with: qfprog --help

# (2.5) Serial Terminal Application: for communicating for the Hardware Board
sudo apt-get install putty -y
# Note: To access serial ports on Linux, the user must be added to the "dialout" group.
#- Output of: id -Gn $USER | grep -c "dialout"
#-- 1: already in group
#-- 0: not in group
#- to add in dialout group, type: sudo usermod -a -G dialout $USER

# (2.6) Test the QuickFeather USB-CDC Port
# Verification that the drivers are installed correctly. The details are on the followng link:
# https://qorc-sdk.readthedocs.io/en/latest/qorc-setup/quickstart.html#test-the-quickfeather-usb-cdc-port
# Note: I had to check for different USB ports (3.0/2.0) before it appears on my connected usb devices list.

# (2.7) Bootloader Update
# It is recommended to use the latest bootloader. Details in the following link:
# https://qorc-sdk.readthedocs.io/en/latest/qorc-setup/quickstart.html#bootloader-update
# Note: In my case, it was the latest version already (v1.10.0 from May 2021)

# (2.8) Final checks to verify the flashing of Software (for ARM M4 CPU) and Hardware Logic (for eFPGA)


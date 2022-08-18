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
#	Software: Raspberry Pi OS (64-bit) (Debian 11) 
#	uname -a: Linux pi4 5.15.32-v8+ #1538 SMP PREEMPT Thu Mar 31 19:40:39 BST 2022 aarch64 GNU/Linux
#	FPGA	: SparkFun Thing Plus (QuickLogic EOS S3)

# setting some variables
export F4PGA_INSTALL_DIR=~/opt/f4pga
export FPGA_FAM=eos-s3


# INSTALLATION:
# ------------
# Guide: https://f4pga-examples.readthedocs.io/en/latest/getting.html

# Prerequisites
echo "[LOG]: Installing updates and prerequisites"
apt update -y
apt install -y git wget xz-utils

# Actual toolchain
echo "[LOG]: Installing conda"
# (1) conda (couldn't install latest version, 4.9.2 worked and then updated to latest conda)
# helpful links: 
# - https://stackoverflow.com/questions/61508312/installing-anaconda-on-raspberry-pi-4-with-ubuntu-20-04
# - https://github.com/conda/conda/issues/10723
# - enviornment.yml is from f4pga examples repo: https://github.com/chipsalliance/f4pga-examples/blob/main/eos-s3
# -- but only yosys, vtr and yosys-symbiflow-plugins were installed but mnaually
# help on errors:
# - https://stackoverflow.com/questions/58219956/how-to-fix-resolvepackagenotfound-error-when-creating-conda-environment
# - https://stackoverflow.com/questions/55554431/conda-fails-to-create-environment-from-yml/55576493#55576493
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-aarch64.sh
bash Miniconda3-py39_4.9.2-Linux-aarch64.sh 
# do not update conda!!!

# (2) QuickLogic FPGA Build Toolchain (compile from source)
# help: https://github.com/QuickLogic-Corp/quicklogic-fpga-toolchain#2-compile-from-source-code-and-run-example-1
# (2.1) QuickLogic-Yosys
git clone https://github.com/QuickLogic-Corp/yosys.git -b quicklogic-rebased quicklogic-yosys
cd quicklogic-yosys
#compiling using gcc
make config-gcc
make install PREFIX="/home/frasheed-dev/opt/quicklogic-yosys"
export PATH="/home/frasheed-dev/opt/quicklogic-yosys/bin:$PATH"
cd ..

# (2.2) Yosys-f4pga/symbiflow-plugins (not installed: ql-qlf systemverilog dsp-ff)
git clone 
cd yosys-f4pga-plugins
#open Makefile_plugin.common and replace YOSYS_PATH with
YOSYS_PATH = /opt/quicklogic-yosys/
#Note: ql-qlf-plugin was reporting undeclared variable and was removed from Makefile plugins list

#- (2.3) Verilog to Routing (VTR) (compiled from source)
git clone https://github.com/SymbiFlow/vtr-verilog-to-routing
cd vtr-verilog-to-routing
#-- run "make" in root folder of the Verilog to Routing (VTR)
make
#-- VTR has a graphics support for easy visualization. However, it maybe disabled due 
#--- to missing libraries. Take a look at log of make (or make install) to know missing libraries.
#--- in make log: "-- EZGL: graphics disabled" if missing libraries
cd build  
#set installation directory
cmake -DCMAKE_INSTALL_PREFIX=~/opt/vtr ..
make install
export PATH="/home/frasheed-dev/opt/vtr/bin:$PATH"
#-- Installation verification
python run_quick_test.py

#- (2.4) F4PGA/Symbiflow Intallation
# Not all packages support aarch64 architecture so setup is manual and packages are installed manually
# NEVER UPDATE CONDA OR PIP PACKAGES, ELSE IT WILL GIVE "ILLEGAL INSTRUCTION" ERROR DUE TO WRONG PACKAGE INSTALLATION FOR THIS ARCHITECTURE
export F4PGA_PACKAGES='install-ql ql-eos-s3_wlcsp'

conda create --name $FPGA_FAM
conda activate $FPGA_FAM
# followed f4pga guide (August 2022)
git clone https://github.com/chipsalliance/f4pga-examples
cd f4pga-examples
pip install -r ./eos-s3/requirements.txt 

# Download architecture definitions (for Quicklogic EOS-S3)
mkdir -p $F4PGA_INSTALL_DIR/$FPGA_FAM
F4PGA_TIMESTAMP='20220803-160711'
F4PGA_HASH='df6d9e5'
for PKG in $F4PGA_PACKAGES; do
  wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${PKG}-${F4PGA_HASH}.tar.xz | tar -xJC $F4PGA_INSTALL_DIR/${FPGA_FAM}
done

# (3) QOR SDK Installation
# (3.1) QORC SDK Submodules
git clone https://github.com/QuickLogic-Corp/qorc-sdk.git
cd qorc-sdk
git submodule update --init qorc-example-apps
git submodule update --init qorc-testapps
git submodule update --init s3-gateware

# (3.2) ARM Cortex M4 Build Toolchain
# I had gcc version 10.2.1 20210110 (Debian 10.2.1-6) so, I installed "10-2020-q4-major" release from:
#- https://developer.arm.com/downloads/-/gnu-rm
wget -O gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 -q --show-progress --progress=bar:force 2>&1 "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2?revision=cff794bc-3fb1-4c9c-934b-782886767324&hash=50FBD97155D0006C0BA3099C44BE064F"
mkdir arm_toolchain_install
tar xvjf gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2  -C ${PWD}/arm_toolchain_install
# temporary add path for current session (for pemenant adding to PATH, copy the next line with complete path to ~/.bashrc or ~/.bash_profile)
export PATH=${PWD}/arm_toolchain_install/gcc-arm-none-eabi-10-2020-q4-major/bin:$PATH
cd ..

# (3.3) QuickLogic TinyFPGA-Programmer-Application
git clone --recursive https://github.com/QuickLogic-Corp/TinyFPGA-Programmer-Application.git
pip install tinyfpgab
pip install -U apio
apio drivers --serial-enable
# Restart OS!
# temporary alias set for current session (for permenant alias, add the next line with complete path to ~/.bashrc or ~/.bash_profile)
alias qfprog="python ${PWD}/TinyFPGA-Programmer-Application/tinyfpga-programmer-gui.py"
# test programmer application with: qfprog --help

# (3.4) Serial Terminal Application: for communicating for the Hardware Board
sudo apt-get install putty -y
# Note: To access serial ports on Linux, the user must be added to the "dialout" group.
#- Output of: id -Gn $USER | grep -c "dialout"
#-- 1: already in group
#-- 0: not in group
#- to add in dialout group, type: sudo usermod -a -G dialout $USER

# (3.5) Test the QuickFeather USB-CDC Port
# Verification that the drivers are installed correctly. The details are on the followng link:
# https://qorc-sdk.readthedocs.io/en/latest/qorc-setup/quickstart.html#test-the-quickfeather-usb-cdc-port
# Note: I had to check for different USB ports (3.0/2.0) before it appears on my connected usb devices list.
# - Also, for the first start BLUE LED was flashing very slowly and the device didn't appear after it turned off. 
# - I waited around 10 minutes in this state and pressed the "restart" button of he board and then it was blinking faster
# - and also appeared in the connected usb list

# (3.6) Bootloader Update
# It is recommended to use the latest bootloader. Details in the following link:
# https://qorc-sdk.readthedocs.io/en/latest/qorc-setup/quickstart.html#bootloader-update
# Note: In my case, it was the latest version already (v1.10.0 from May 2021)

# (3.7) Final checks to verify the flashing of Software (for ARM M4 CPU) and Hardware Logic (for eFPGA)


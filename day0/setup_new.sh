#------------------------------------------------------------------
# Description	: Setup file for installing the Prerequisites for the
# 				  toolchain (for ubuntu based systems).
# Author		: Farhan Rasheed
# Email			: frasheed.dev@gmail.com
# GitHub		: https://github.com/frasheed-dev/
#------------------------------------------------------------------

# INFORMATION:
# ----------- 
#	(1)	This script is sourced with sudo -s source setup.sh
#	(2)	setup.sh is developed for:
#		Hardware: Raspberry Pi 4 Model B Rev 1.4 (4GB RAM) 
#		Software: Raspberry Pi OS (64-bit)  
#		uname -a: Linux pi4 5.15.32-v8+ #1538 SMP PREEMPT Thu Mar 31 19:40:39 BST 2022 aarch64 GNU/Linux
#		FPGA	: QuickLogic EOS S3

# INSTALLATION:
# ------------
# Guide: https://f4pga-examples.readthedocs.io/en/latest/getting.html

# Prerequisites
echo "[LOG]: Installing updates and prerequisites"
apt update -y
apt install -y git wget xz-utils

# Actual toolchain
echo "[LOG]: Installing conda"
# (1) conda (couldn't install latest version, 4.9.2 worked)
# helpful links: 
# (1.1) https://stackoverflow.com/questions/61508312/installing-anaconda-on-raspberry-pi-4-with-ubuntu-20-04
# (1.2) https://github.com/conda/conda/issues/10723
# (1.3) https://repo.anaconda.com/miniconda/

export F4PGA_INSTALL_DIR=~/opt/f4pga
export FPGA_FAM=eos-s3
#- miniconda didnt work so used miniconda from miniforge3
#- created conda environment

# installed packages manually from enviornment.yml and requirements.txt
#-- specially: 
#--- (1) f4pga installed from https://github.com/chipsalliance/f4pga/archive/main.zip#subdirectory=f4pga
#---- how: (1.1) svn checkout https://github.com/chipsalliance/f4pga/trunk/f4pga
#--------- (1.2) cd f4pga/
#--------- (1.3) sudo python setup.py install


#--- 21) quicklogic-fasm installed from https://github.com/QuickLogic-Corp/quicklogic-fasm
#---- how: (2.1) git clone https://github.com/QuickLogic-Corp/quicklogic-fasm
#--------- (2.2) cd quicklogic-fasm/
#--------- (2.3) sudo python setup.py install


#- compiled yosys from f4pga rep.
#-- https://github.com/SymbiFlow/yosys

#- and Verilog to Routing (VTR) (compiled from source)
#-- https://github.com/SymbiFlow/vtr-verilog-to-routing
#-- just run "make" in root folder of the Verilog to Routing (VTR) 
#-- and in that $ROOT_VTR/folder vpr/vpr will be the executable file

#- and compiled yosys plugins (QuickLogic QLF FPGAs plugin didn't compile) from f4pga rep.
# according to f4pga guide, only SystemVerilog plugin (read_system_bverilog, read_uhdm) is required
#-- https://github.com/chipsalliance/yosys-f4pga-plugins

wget http://repo.continuum.io/miniconda/Miniconda3-py37_4.11.0-Linux-aarch64.sh -O conda_installer.sh
bash conda_installer.sh -u -b -p $F4PGA_INSTALL_DIR/$FPGA_FAM/conda;
source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh";

# enviornment.yml is from f4pga examples repo: https://github.com/chipsalliance/f4pga-examples/blob/main/eos-s3
# help on errors:
# (1.4) https://stackoverflow.com/questions/58219956/how-to-fix-resolvepackagenotfound-error-when-creating-conda-environment
# (1.5) https://stackoverflow.com/questions/55554431/conda-fails-to-create-environment-from-yml/55576493#55576493
echo "[LOG]: Creating conda environment"
conda env create -f $FPGA_FAM/environment.yml

echo "[LOG]: Installing architecture definitions"
# (2) Download architecture definitions (for Quicklogic EOS-S3)
wget -qO- https://storage.googleapis.com/symbiflow-arch-defs-install/quicklogic-arch-defs-qlf-fc5d8da.tar.gz | tar -xzC $F4PGA_INSTALL_DIR/$FPGA_FAM/

echo "DONE!"

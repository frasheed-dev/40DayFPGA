# DETAILS:
# -------
# This example design features a simple 4-bit counter driving LEDs. 

export F4PGA_INSTALL_DIR=~/opt/f4pga
export FPGA_FAM="eos-s3"

export PATH="$F4PGA_INSTALL_DIR/$FPGA_FAM/quicklogic-arch-defs/bin:$PATH";
export F4PGA_ENV_BIN="$F4PGA_INSTALL_DIR/$FPGA_FAM/quicklogic-arch-defs/bin";
export F4PGA_ENV_SHARE="$F4PGA_INSTALL_DIR/$FPGA_FAM/quicklogic-arch-defs/share/symbiflow";
#source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh"

conda activate $FPGA_FAM

make -C btn_counter

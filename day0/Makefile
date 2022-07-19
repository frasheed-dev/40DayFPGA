#https://f4pga-examples.readthedocs.io/en/latest/getting.html

F4PGA_INSTALL_DIR=~/opt/f4pga
FPGA_FAM=eos-s3

update: echo "THIS"
#apt update \-y
#apt install \-y git wget xz-utils

tool_chain: wget https\://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda_installer        
	bash conda_installer.sh -u -b -p $F4PGA_INSTALL_DIR/$FPGA_FAM/conda
	source "$(F4PGA_INSTALL_DIR)/$(FPGA_FAM)/conda/etc/profile.d/conda.sh"
	conda env create -f $(FPGA_FAM)/environment.yml

	

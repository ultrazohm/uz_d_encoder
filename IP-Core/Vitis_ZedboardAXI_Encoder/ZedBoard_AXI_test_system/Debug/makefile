#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/zed/export/zed/zed.xpfm
SYS_CONFIG = zed
DOMAINS = domain_ps7_cortexa9_0
BIF_PATH = C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test_system/Debug/system.bif

BITSTREAM_PATH = C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test/_ide/bitstream/design_1_wrapper.bit
SD_FILES = --elf C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test/Debug/ZedBoard_AXI_test.elf,ps7_cortexa9_0

#
# primary build targets
#

all: package

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 50095 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean



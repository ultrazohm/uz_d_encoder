connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zed 210248A399F6" && level==0 && jtag_device_ctx=="jsn-Zed-210248A399F6-23727093-0"}
fpga -file C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/zed/export/zed/hw/design_1_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/FelixKaiser/Documents/3_EAL_Playground/ZedboardAXI_Encoder/ZedBoard_AXI_test/Debug/ZedBoard_AXI_test.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con

# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\system_verilog\0504_SPI_2\vitis_workplace\SPI_2_system\_ide\scripts\debugger_spi_2-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\system_verilog\0504_SPI_2\vitis_workplace\SPI_2_system\_ide\scripts\debugger_spi_2-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183B31B0FA" && level==0 && jtag_device_ctx=="jsn-Basys3-210183B31B0FA-0362d093-0"}
fpga -file D:/system_verilog/0504_SPI_2/vitis_workplace/SPI_2/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Basys3 210183B31B0FA" && jtag_device_ctx=="jsn-Basys3-210183B31B0FA-0362d093-0"}
loadhw -hw D:/system_verilog/0504_SPI_2/vitis_workplace/design_1_wrapper/export/design_1_wrapper/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Basys3 210183B31B0FA" && jtag_device_ctx=="jsn-Basys3-210183B31B0FA-0362d093-0"}
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Basys3 210183B31B0FA" && jtag_device_ctx=="jsn-Basys3-210183B31B0FA-0362d093-0"}
dow D:/system_verilog/0504_SPI_2/vitis_workplace/SPI_2/Debug/SPI_2.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Basys3 210183B31B0FA" && jtag_device_ctx=="jsn-Basys3-210183B31B0FA-0362d093-0"}
con

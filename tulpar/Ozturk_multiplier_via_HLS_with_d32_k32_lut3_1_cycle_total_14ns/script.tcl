############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
############################################################
open_project vcu118_big_mul_k32_d32
set_top big_mul
add_files big_mul_hls.cpp
open_solution "solution1"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 20 -name default
config_export -format ip_catalog -rtl verilog -vivado_optimization_level 2 -vivado_phys_opt place -vivado_report_level 0
config_sdx -optimization_level none -target none
set_clock_uncertainty 12.5%
#csim_design
csynth_design
#cosim_design
export_design -flow impl -rtl verilog -format ip_catalog

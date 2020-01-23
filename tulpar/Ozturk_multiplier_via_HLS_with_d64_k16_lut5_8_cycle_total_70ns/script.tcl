############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
############################################################
open_project vcu118_big_mul_large_4
set_top big_mul
add_files vcu118_big_mul_large_4/big_mul_hls.cpp
add_files vcu118_big_mul_large_4/lut51_d64_k16.h
add_files vcu118_big_mul_large_4/lut52_d64_k16.h
add_files vcu118_big_mul_large_4/lut53_d16_k16.h
add_files vcu118_big_mul_large_4/lut53_d64_k16.h
add_files vcu118_big_mul_large_4/lut54_d64_k16.h
add_files vcu118_big_mul_large_4/lut55_d64_k16.h
add_files vcu118_big_mul_large_4/lut56_d64_k16.h
add_files vcu118_big_mul_large_4/lut57_d64_k16.h
add_files vcu118_big_mul_large_4/lut58_d64_k16.h
add_files vcu118_big_mul_large_4/lut59_d64_k16.h
add_files vcu118_big_mul_large_4/lut5A_d64_k16.h
add_files vcu118_big_mul_large_4/lut5B_d64_k16.h
add_files vcu118_big_mul_large_4/lut5C_d64_k16.h
add_files vcu118_big_mul_large_4/lut5D_d64_k16.h
open_solution "solution1"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 3 -name default
config_sdx -target none
config_export -vivado_optimization_level 2 -vivado_phys_opt place -vivado_report_level 0
set_clock_uncertainty 12.5%
#source "./vcu118_big_mul_large_4/solution1/directives.tcl"
#csim_design
csynth_design
#cosim_design
export_design -format ip_catalog

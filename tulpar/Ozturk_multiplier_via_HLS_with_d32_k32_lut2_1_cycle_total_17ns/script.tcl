############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
############################################################
open_project vcu118_big_mul_k32_d32_lut2
set_top big_mul
add_files big_mul_hls.cpp
open_solution "solution1"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 18 -name default
#csim_design
csynth_design
#cosim_design
export_design -format ip_catalog

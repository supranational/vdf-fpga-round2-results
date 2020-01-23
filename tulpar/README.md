


# Tulpar
Low-latency modular multiplication implementations of Ozturk modular multiplication method via high-level synthesis tool are presented in this repository to be an entry for VDF FPGA Competition evaluation.

## Introduction
This repository contains several implementations of Ozturk modulo multiplier with a low-latency objective (see the full paper for the algorithm https://eprint.iacr.org/2019/826). Algorithm 7 and 9 that are proposed in the paper are combined and described as a single C function called `big_mul`.  The C description of the Ozturk modulo multiplication algorithm has several loops for the multplication and addition chains. In order to make them as a single operation, special pragma directives has to be inserted into the C description of the algorithm. These pragma insertions are described below as general design guideline. Each design has diffferent combinations of these pragmas in order to achieve the minimum critical path to meet the desired low-latency objective. The hardware designs given in this repository are the ones that achieves the best low-latency implementations of my experiments.

## Folder Structure
Each design has a special folder that starts with 'Ozturk_multiplier_via_HLS' and also indicates the achieved total latency for one modulo multiplication with the selected d and k values. This repoistory has 4 different implementations:
* Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns
* Ozturk_multiplier_via_HLS_with_d64_k16_lut5_1_cycle_total_14ns
* Ozturk_multiplier_via_HLS_with_d32_k32_lut2_1_cycle_total_17ns
* Ozturk_multiplier_via_HLS_with_d64_k16_lut5_8_cycle_total_70ns

Folder structure of the designs are similar to eachother. They have special README file ( [see for instance](Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns/README.md) ) that summarizes the Vivado HLS report to show the achieved estimate clock frequency, number of cycles and utilization of the FPGA resources. The complete report can be found in this directory:
`/Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns/solution1/syn/report`

Each folder has also a script file which is  `script.tcl` and it allows one to compile and synthesize the given source codes to generate the same hardware design with the given constraints.

The HLS firedly C descriptions has beed presented in this repository for different design metrics and it is named as `big_mul_hls.cpp` for each design. 

The look-up tables for the modulo reduction that is presented by Ozturk has been descibed as 3-dimensional array and named as `LUT#`. These look-up tables are defined in header files such as `lut31_d32_k32.h`  ( [see for instance](Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns/lut31_d32_k32.h) ) .

The pre-synthesized  Verilog and SystemC codes can be found in the `syn` folder for each design. Vivado HLS reports for each design can also be found in the report folder under `syn` directory.

Each folder has also a unique Python script in order to verify the Ozturk algorithm wiht the selected configurations and to generate the necessary LUTs as a 3-dimensional arrays such as `d_32_n1024_LUT3_verify_my_modified_algorithm7_other_architectures.py`  ( [see for instance](Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns/d_32_n1024_LUT3_verify_my_modified_algorithm7_other_architectures.py) ) .
In the beginning of the Python scripts, there are special flags to enable or disable the generation of the LUT tables and Debug mode to verify the algorithm with the selected configuration for different d, k and LUT values.


## General Design Guideline using Vivado HLS

```c
void big_mul(ap_uint<(33)> z[k+1], ap_uint<(33)> x[k+1], ap_uint<(33)> y[k+1]){

// ARRAY_RESHAPE pragma is used to decompose the arrays x,y and z and
// to create a very wide register
#pragma HLS ARRAY_RESHAPE variable=x complete dim=1
#pragma HLS ARRAY_RESHAPE variable=y complete dim=1
#pragma HLS ARRAY_RESHAPE variable=z complete dim=1

// PIPELINE pragma specifies the desired initiation interval for the
// region If the tool achieves one cycle latency, a new input can be
// accepted by the big_mul accelerator with the help of PIPELINE
// pragma in order to initiate a new modulo multiplication.
#pragma HLS PIPELINE II=1

// LATENCY pragma with min and max of one cycle forces the tool to
// generate a hardware thta completes the function in one cycle if
// there is no dependency and any other physical constarint such as
// limited number of ports of the memories in the
#pragma HLS LATENCY max=1 min=1

// D array has been defined as 2*d bit C arrays and it is also
// transformed into a single element whose bitlength is 64*(2*k+3) by
// using the ARRAY_RESHAPE pragma on this array in order to make it
// available for necessary computation in one cycle. The same
// methodology is applied to all the other arrays defined in the
// function in order to concatenate the array elements of the arrays
// by increasing bit-widths. This simply allows all the array elements
// to be accessed in a single cycle.
ap_uint<64> D[2*k+3]; // width 2*d
#pragma HLS ARRAY_RESHAPE variable=D complete dim=1

...
// UNROLL pragma is used to unroll the looop and create multiple
// independent operations of the loop body. Since we already reshaped
// the array to make all the elements completeley available for each
// independent operations, the loop will be automatically be unrolled
// and one cycle latency will be achieved.
     for(i=0; i<k; i++){
#pragma HLS UNROLL factor=32//k-1
...
  
}
```

### Integer d+1 bit multiplier 
Special d+1 bit multiplier has been defined as a seperate function. `mulhilo` function takes x and y as d+1 bit values and produces  d-bit high and low parts of the multiplication result with 2-bit most significant part of the result.

```c
void mulhilo(ap_uint<33> x, ap_uint<33> y, ap_uint<32> *hi, ap_uint<32> *lo, ap_uint<2> *redundant){ // x width d+1, y width d+1, hi width d, lo width d,
    ap_uint<66> res = (ap_uint<66>) x * (ap_uint<66>) y; // width 2*d+2
    *lo = res;
    *hi = res >> d;
    *redundant = res >> 2*d;
}
```

### Look-up tables for the modular reduction

For each design, special look-up tables needed for the modula reduction whose algorithm is presented in Ozturk's paper (see the full paper for the algorithm https://eprint.iacr.org/2019/826).

`LUT51`  array that is used in `Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns` design is found in `lut51_d64_k16.h` and demonstrated below. It is simply generated with a python script given in each folder  ( [see for instance](Ozturk_multiplier_via_HLS_with_d64_k16_lut5_1_cycle_total_14ns/d_64_n1024_LUT5_verify_my_modified_algorithm7_other_architectures.py) ) .
```c
#include "ap_int.h"

ap_uint<64> LUT51[ 19 ][ 16 ][ 32 ] = {
{ 
{ 0x0 , 0xb99084fb771d9995 , 0x732109f6ee3b332a , 0xe64213eddc766654 , 0x9fd298e95393ffe9 , 0x12f3a2e041cf3313 , 0xcc8427dbb8eccca8 , 0x3fa531d2a727ffd2 , 0xf935b6ce1e459967 , 0x6c56c0c50c80cc91 , 0x25e745c0839e6626 , 0xdf77cabbfabbffbb , 0x5298d4b2e8f732e5 , 0xc2959ae6014cc7a , 0x7f4a63a54e4fffa4 , 0x38dae8a0c56d9939 , 0xabfbf297b3a8cc63 , 0x658c77932ac665f8 , 0xd8ad818a19019922 , 0x923e0685901f32b7 , 0x4bce8b81073ccc4c , 0xbeef9577f577ff76 , 0x78801a736c95990b , 0xeba1246a5ad0cc35 , 0xa531a965d1ee65ca , 0x1852b35cc02998f4 , 0xd1e3385837473289 , 0x4504424f258265b3 , 0xfe94c74a9c9fff48 , 0x71b5d1418adb3272 , 0x2b46563d01f8cc07 , 0xe4d6db387916659c},
...
```
`LUT31`  array that is used in `Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns` design is found in `lut31_d32_k32.h` and demonstrated below. It is simply generated with a python script given in each folder.
```c
#include "ap_int.h"

ap_uint<32> LUT31[ 35 ][ 32 ][ 8 ] = {
{ 
{ 0x0 , 0x771d9995 , 0xee3b332a , 0xdc766654 , 0x5393ffe9 , 0x41cf3313 , 0xb8eccca8 , 0xa727ffd2},
{ 0x0 , 0xb99084fb , 0x732109f6 , 0xe64213ed , 0x9fd298e9 , 0x12f3a2e0 , 0xcc8427db , 0x3fa531d2},
...
```
`LUT21`  array that is used in `Ozturk_multiplier_via_HLS_with_d32_k32_lut2_1_cycle_total_17ns` design is found in `lut21_d32_k32.h` and demonstrated below. It is simply generated with a python script given in each folder.
```c
#include "ap_int.h"

ap_uint<32> LUT21[ 35 ][ 32 ][ 4 ] = {
{ 
{ 0x0 , 0x771d9995 , 0xee3b332a , 0xdc766654},
{ 0x0 , 0xb99084fb , 0x732109f6 , 0xe64213ed},
{ 0x0 , 0xafb4a2cf , 0x5f69459f , 0xbed28b3e},
{ 0x0 , 0xb126211d , 0x624c423b , 0xc4988476},
...
```
`LUT10`  array that is used in `Ozturk_multiplier_via_HLS_with_d32_k32_lut2_1_cycle_total_17ns` design is found in `lut10_d32_k32.h` and demonstrated below. It is simply generated with a python script given in each folder.
```c
#include "ap_int.h"

ap_uint<32> LUT10[ 35 ][ 32 ][ 2 ] = {
{ 
{ 0x0 , 0x34793bcb},
{ 0x0 , 0xa5cfbc24},
{ 0x0 , 0x47646183},
{ 0x0 , 0x8ac2bf5c},
...
```

## Interface of the hardware generated by Vivado HLS using the presented C codes in this repository

This is the interface of the presented architectures that are generated by the Vivado HLS tool. They have common accelerator interface ap_control signals and the control signals and the other signals of the IP core has been defined below. 

```verilog
module big_mul (
        ap_clk,// clock
        ap_rst,// reset
        ap_start, // starts the modulo multiplication of x_V and y_V inputs
        ap_done, // indicates that the operation is done 
        ap_idle, // indicates when the IP core is idle that means there is no operation currently being performed
        ap_ready, // indicates the modulo multiplication is ready to accept a new input
        z_V_i, // should be simply been driven by zero
        z_V_o, // is the result of the modulo multiplication operation under fixed modulus selected by the competition.
        z_V_o_ap_vld, // indicates the cycles when z_V_o signal has the correct result, this is simply valid signal
        x_V, // is one of the modulo multiplication inputs
        y_V // is the second input of the modulo multiplication
);

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [1088:0] z_V_i;
output  [1088:0] z_V_o;
output   z_V_o_ap_vld;
input  [1088:0] x_V;
input  [1088:0] y_V;
```
The big_mul IP cores can be instantiated in a modulo squarer wrapper file which simply connects the output of the modulo multiplier into its both inputs to compute the modulo square operation.

## Running the script to generate the same hardware as the given in this repository on your own platform

You need to change your directory to the folder that contains the source codes of the design. Since each design has its unique script file to generate the Verilog codes. Then, simply run the `script.tcl` file with `vivado_hls`  program. An example of how to start the compilation and synthesis is given below.
```bash
cd ~/Ozturk_multiplier_via_HLS_with_d32_k32_lut3_1_cycle_total_14ns
vivado_hls -f script.tcl
```

## HLS implementation of Ozturk modulo multiplier when d=32, k=32 and LUT3 is considered

Brief summary of Vivado HLS report for this design is given below. It completes the modulo multiplication operation on 1 cycle and 14ns taken from Vivado HLS report.
```

================================================================
== Vivado HLS Report for 'big_mul'
================================================================
* Date:           Tue Dec 31 09:44:25 2019

* Version:        2019.2 (Build 2704478 on Wed Nov 06 22:10:23 MST 2019)
* Project:        vcu118_big_mul_k32_d32
* Solution:       solution1
* Product family: virtexuplus
* Target device:  xcvu9p-flga2104-2L-e


================================================================
== Performance Estimates
================================================================
+ Timing: 
    * Summary: 
    +--------+----------+-----------+------------+
    |  Clock |  Target  | Estimated | Uncertainty|
    +--------+----------+-----------+------------+
    |ap_clk  | 20.00 ns | 13.881 ns |   2.50 ns  |
    +--------+----------+-----------+------------+

+ Latency: 
    * Summary: 
    +---------+---------+-----------+-----------+-----+-----+----------+
    |  Latency (cycles) |   Latency (absolute)  |  Interval | Pipeline |
    |   min   |   max   |    min    |    max    | min | max |   Type   |
    +---------+---------+-----------+-----------+-----+-----+----------+
    |        1|        1| 20.000 ns | 20.000 ns |    1|    1| function |
    +---------+---------+-----------+-----------+-----+-----+----------+

================================================================
== Utilization Estimates
================================================================
* Summary: 
+---------------------+---------+-------+---------+---------+-----+
|         Name        | BRAM_18K| DSP48E|    FF   |   LUT   | URAM|
+---------------------+---------+-------+---------+---------+-----+
|DSP                  |        -|      -|        -|        -|    -|
|Expression           |        -|      -|        0|   514183|    -|
|FIFO                 |        -|      -|        -|        -|    -|
|Instance             |        -|   4356|        0|    22869|    -|
|Memory               |        0|      -|   382600|    47999|    -|
|Multiplexer          |        -|      -|        -|        -|    -|
|Register             |        -|      -|     2406|        -|    -|
+---------------------+---------+-------+---------+---------+-----+
|Total                |        0|   4356|   385006|   585051|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available SLR        |     1440|   2280|   788160|   394080|  320|
+---------------------+---------+-------+---------+---------+-----+
|Utilization SLR (%)  |        0|    191|       48|      148|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available            |     4320|   6840|  2364480|  1182240|  960|
+---------------------+---------+-------+---------+---------+-----+
|Utilization (%)      |        0|     63|       16|       49|    0|
+---------------------+---------+-------+---------+---------+-----+

```
## HLS implementation of Ozturk modulo multiplier when d=64, k=16 and LUT5 is considered

Brief summary of Vivado HLS report for this design is given below. It completes the modulo multiplication operation on 1 cycle and 14ns taken from Vivado HLS report.
```
================================================================
== Vivado HLS Report for 'big_mul'
================================================================
* Date:           Fri Dec 20 11:05:46 2019

* Version:        2019.2 (Build 2704478 on Wed Nov 06 22:10:23 MST 2019)
* Project:        vcu118_big_mul_large_3
* Solution:       solution1
* Product family: virtexuplus
* Target device:  xcvu9p-flga2104-2L-e


================================================================
== Performance Estimates
================================================================
+ Timing: 
    * Summary: 
    +--------+----------+-----------+------------+
    |  Clock |  Target  | Estimated | Uncertainty|
    +--------+----------+-----------+------------+
    |ap_clk  | 30.00 ns | 13.844 ns |   3.75 ns  |
    +--------+----------+-----------+------------+

+ Latency: 
    * Summary: 
    +---------+---------+-----------+-----------+-----+-----+---------+
    |  Latency (cycles) |   Latency (absolute)  |  Interval | Pipeline|
    |   min   |   max   |    min    |    max    | min | max |   Type  |
    +---------+---------+-----------+-----------+-----+-----+---------+
    |        1|        1| 30.000 ns | 30.000 ns |    1|    1|   none  |
    +---------+---------+-----------+-----------+-----+-----+---------+

================================================================
== Utilization Estimates
================================================================
* Summary: 
+---------------------+---------+-------+---------+---------+-----+
|         Name        | BRAM_18K| DSP48E|    FF   |   LUT   | URAM|
+---------------------+---------+-------+---------+---------+-----+
|DSP                  |        -|      -|        -|        -|    -|
|Expression           |        -|      -|        0|   576548|    -|
|FIFO                 |        -|      -|        -|        -|    -|
|Instance             |        -|   4624|        0|    17051|    -|
|Memory               |        -|      -|   252928|   126464|    -|
|Multiplexer          |        -|      -|        -|       15|    -|
|Register             |        -|      -|     2045|        -|    -|
+---------------------+---------+-------+---------+---------+-----+
|Total                |        0|   4624|   254973|   720078|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available SLR        |     1440|   2280|   788160|   394080|  320|
+---------------------+---------+-------+---------+---------+-----+
|Utilization SLR (%)  |        0|    202|       32|      182|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available            |     4320|   6840|  2364480|  1182240|  960|
+---------------------+---------+-------+---------+---------+-----+
|Utilization (%)      |        0|     67|       10|       60|    0|
+---------------------+---------+-------+---------+---------+-----+
```

## HLS implementation of Ozturk modulo multiplier when d=32, k=32 and LUT2 is considered

Brief summary of Vivado HLS report for this design is given below. It completes the modulo multiplication operation on 1 cycle and 17ns taken from Vivado HLS report.
```
================================================================
== Vivado HLS Report for 'big_mul'
================================================================
* Date:           Tue Dec 31 00:52:03 2019

* Version:        2019.1.op (Build 2552052 on Fri May 24 15:28:33 MDT 2019)
* Project:        vcu118_big_mul_k32_d32_lut2
* Solution:       solution1
* Product family: virtexuplus
* Target device:  xcvu9p-flga2104-2L-e


================================================================
== Performance Estimates
================================================================
+ Timing (ns): 
    * Summary: 
    +--------+-------+----------+------------+
    |  Clock | Target| Estimated| Uncertainty|
    +--------+-------+----------+------------+
    |ap_clk  |  18.00|    16.615|        2.25|
    +--------+-------+----------+------------+

+ Latency (clock cycles): 
    * Summary: 
    +-----+-----+-----+-----+----------+
    |  Latency  |  Interval | Pipeline |
    | min | max | min | max |   Type   |
    +-----+-----+-----+-----+----------+
    |    1|    1|    1|    1| function |
    +-----+-----+-----+-----+----------+

================================================================
== Utilization Estimates
================================================================
* Summary: 
+---------------------+---------+-------+---------+---------+-----+
|         Name        | BRAM_18K| DSP48E|    FF   |   LUT   | URAM|
+---------------------+---------+-------+---------+---------+-----+
|DSP                  |        -|      -|        -|        -|    -|
|Expression           |        -|      -|        0|   775543|    -|
|FIFO                 |        -|      -|        -|        -|    -|
|Instance             |        -|   4356|        0|   319893|    -|
|Memory               |        -|      -|        -|        -|    -|
|Multiplexer          |        -|      -|        -|        -|    -|
|Register             |        -|      -|        2|        -|    -|
+---------------------+---------+-------+---------+---------+-----+
|Total                |        0|   4356|        2|  1095436|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available SLR        |     1440|   2280|   788160|   394080|  320|
+---------------------+---------+-------+---------+---------+-----+
|Utilization SLR (%)  |        0|    191|    ~0   |      277|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available            |     4320|   6840|  2364480|  1182240|  960|
+---------------------+---------+-------+---------+---------+-----+
|Utilization (%)      |        0|     63|    ~0   |       92|    0|
+---------------------+---------+-------+---------+---------+-----+
```

## HLS implementation of Ozturk modulo multiplier when d=64, k=16 and LUT5 is considered

Brief summary of Vivado HLS report for this design is given below. It completes the modulo multiplication operation on 8 cycle and 71ns taken from Vivado HLS report.
```
================================================================
== Vivado HLS Report for 'big_mul'
================================================================
* Date:           Tue Dec 31 08:44:35 2019

* Version:        2019.2 (Build 2704478 on Wed Nov 06 22:10:23 MST 2019)
* Project:        vcu118_big_mul_large_4
* Solution:       solution1
* Product family: virtexuplus
* Target device:  xcvu9p-flga2104-2L-e


================================================================
== Performance Estimates
================================================================
+ Timing: 
    * Summary: 
    +--------+---------+----------+------------+
    |  Clock |  Target | Estimated| Uncertainty|
    +--------+---------+----------+------------+
    |ap_clk  | 3.00 ns | 8.818 ns |   0.38 ns  |
    +--------+---------+----------+------------+

+ Latency: 
    * Summary: 
    +---------+---------+-----------+-----------+-----+-----+---------+
    |  Latency (cycles) |   Latency (absolute)  |  Interval | Pipeline|
    |   min   |   max   |    min    |    max    | min | max |   Type  |
    +---------+---------+-----------+-----------+-----+-----+---------+
    |        8|        8| 70.542 ns | 70.542 ns |    8|    8|   none  |
    +---------+---------+-----------+-----------+-----+-----+---------+
    
================================================================
== Utilization Estimates
================================================================
* Summary: 
+---------------------+---------+-------+---------+---------+-----+
|         Name        | BRAM_18K| DSP48E|    FF   |   LUT   | URAM|
+---------------------+---------+-------+---------+---------+-----+
|DSP                  |        -|      -|        -|        -|    -|
|Expression           |        -|      -|        0|   575008|    -|
|FIFO                 |        -|      -|        -|        -|    -|
|Instance             |        -|   4608|   202176|    79488|    -|
|Memory               |        -|      -|   215040|   126464|    -|
|Multiplexer          |        -|      -|        -|     7643|    -|
|Register             |        -|      -|    81614|        -|    -|
+---------------------+---------+-------+---------+---------+-----+
|Total                |        0|   4608|   498830|   788603|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available SLR        |     1440|   2280|   788160|   394080|  320|
+---------------------+---------+-------+---------+---------+-----+
|Utilization SLR (%)  |        0|    202|       63|      200|    0|
+---------------------+---------+-------+---------+---------+-----+
|Available            |     4320|   6840|  2364480|  1182240|  960|
+---------------------+---------+-------+---------+---------+-----+
|Utilization (%)      |        0|     67|       21|       66|    0|
+---------------------+---------+-------+---------+---------+-----+

```
These designs need to be placed and routed with Vivado in order to see the achieved clock frequency and resource utilization on the VU9P FPGA. Due to the leack of memory of my system, that part is not completed and I am not sure the achievable clock frequency by this IP core on real VU9P FPGA.

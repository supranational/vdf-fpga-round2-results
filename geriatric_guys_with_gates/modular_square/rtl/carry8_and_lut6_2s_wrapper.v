/*******************************************************************************
  Copyright 2019 Kurt Baty

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

//
// carry8_and_lut6_2s_wrapper
//  rev2
//
//  10/25/2019
//  updated 12/8/2019
//
//  by Kurt Baty
//

(* keep_hierarchy = "yes" *) 
module carry8_and_lut6_2s_wrapper(a,b,c,cin,din,ci,dout,o,co);
   input   [7:0] a,b,c,cin,din;
   input         ci;
   output  [6:0] dout;
   output  [7:0] o;
   output        co;

   wire    [6:0] dout;
   wire    [7:0] o;
   wire          co;

   wire    [7:0] s;
   wire    [7:0] co_wide;


// LUT6: 6-Bit Look-Up Table
//         UltraScale
// Xilinx HDL Libraries Guide, version 2014.1

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst0
   (
      .O6(s[0]),    //1-bit output: LUT
      .O5(dout[0]),   //1-bit output: LUT
      .I0(a[0]),    //1-bit input:  LUT
      .I1(b[0]),    //1-bit input:  LUT
      .I2(c[0]),    //1-bit input:  LUT
      .I3(cin[0]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst1
   (
      .O6(s[1]),    //1-bit output: LUT
      .O5(dout[1]),   //1-bit output: LUT
      .I0(a[1]),    //1-bit input:  LUT
      .I1(b[1]),    //1-bit input:  LUT
      .I2(c[1]),    //1-bit input:  LUT
      .I3(cin[1]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst2
   (
      .O6(s[2]),    //1-bit output: LUT
      .O5(dout[2]),   //1-bit output: LUT
      .I0(a[2]),    //1-bit input:  LUT
      .I1(b[2]),    //1-bit input:  LUT
      .I2(c[2]),    //1-bit input:  LUT
      .I3(cin[2]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst3
   (
      .O6(s[3]),    //1-bit output: LUT
      .O5(dout[3]),   //1-bit output: LUT
      .I0(a[3]),    //1-bit input:  LUT
      .I1(b[3]),    //1-bit input:  LUT
      .I2(c[3]),    //1-bit input:  LUT
      .I3(cin[3]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst4
   (
      .O6(s[4]),    //1-bit output: LUT
      .O5(dout[4]),   //1-bit output: LUT
      .I0(a[4]),    //1-bit input:  LUT
      .I1(b[4]),    //1-bit input:  LUT
      .I2(c[4]),    //1-bit input:  LUT
      .I3(cin[4]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst5
   (
      .O6(s[5]),    //1-bit output: LUT
      .O5(dout[5]),   //1-bit output: LUT
      .I0(a[5]),    //1-bit input:  LUT
      .I1(b[5]),    //1-bit input:  LUT
      .I2(c[5]),    //1-bit input:  LUT
      .I3(cin[5]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT6_2 #(
      .INIT(64'h6996_6996_e8e8_e8e8) // Logic function
   )
   LUT6_2_inst6
   (
      .O6(s[6]),    //1-bit output: LUT
      .O5(dout[6]),   //1-bit output: LUT
      .I0(a[6]),    //1-bit input:  LUT
      .I1(b[6]),    //1-bit input:  LUT
      .I2(c[6]),    //1-bit input:  LUT
      .I3(cin[6]),  //1-bit input:  LUT
      .I4(1'b0),    //1-bit input:  LUT
      .I5(1'b1)     //1-bit input:  LUT
   );

   LUT4 #(
      .INIT(16'h6996) // Logic function
   )
   LUT4_inst
   (
      .O(s[7]),     //1-bit output: LUT
      .I0(a[7]),    //1-bit input:  LUT
      .I1(b[7]),    //1-bit input:  LUT
      .I2(c[7]),    //1-bit input:  LUT
      .I3(cin[7])   //1-bit input:  LUT
   );



// CARRY8: Fast Carry Logic with Look Ahead
//         UltraScale
// Xilinx HDL Libraries Guide, version 2014.1 

   CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8") // 8-bit or dual 4-bit carry (SINGLE_CY8, DUAL_CY4)
   )
   CARRY8_inst (
      .CO(co_wide),      // 8-bit output: Carry-out
      .O(o),             // 8-bit output: Carry chain XOR data out
      .CI(ci),         // 1-bit input : Lower Carry-In
      .CI_TOP(1'b0),   // 1-bit input : Upper Carry-In
      .DI(din),          // 8-bit input : Carry-MUX data in
      .S(s)              // 8-bit input : Carry-MUX select
   );

// End of CARRY8_inst instantiation

   assign co = co_wide[7];


endmodule


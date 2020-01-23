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
//  compressor_3_to_1_8bit_wide
//
//  10/25/2019
//  updated 12/8/2019
//
//  by Kurt Baty
//

module compressor_3_to_1_8bit_wide(
   input  logic [7:0] a,b,c,
   input  logic       c3to2_in,
   input  logic       ci,
   output logic [7:0] o,
   output logic       co
);

   logic   [7:0] din;
   logic   [6:0] dout;

   assign din = {dout,c3to2_in};

   carry8_and_lut6_2s_wrapper c8nlut6_2s_inst(
      .a(a),
      .b(b),
      .c(c),
      .cin(din),
      .din(din),
      .ci(ci),
      .dout(dout),
      .o(o),
      .co(co)
   );

endmodule


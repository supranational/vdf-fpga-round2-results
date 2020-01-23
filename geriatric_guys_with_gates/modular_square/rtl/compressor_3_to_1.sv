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
//  compressor_3_to_1
//
//  10/26/2019
//  updated 12/8/2019
//
//  by Kurt Baty
//

(* keep_hierarchy = "yes" *)
module compressor_3_to_1
 #(
   parameter BIT_LEN = 64
 )
 (
   input  logic [BIT_LEN-1:0]     a,
   input  logic [BIT_LEN-1:0]     b,
   input  logic [BIT_LEN-1:0]     c,
   output logic [BIT_LEN+1:0]     o
 );

   localparam NUM_8BITS = (BIT_LEN+1)/8;
   logic [(NUM_8BITS+1)*8-1:0] wterms[3];
   logic [(NUM_8BITS+1)*8-1:0] wo;
   logic [NUM_8BITS:0]         ci;
   logic [NUM_8BITS:0]         co;

   assign wterms[0] = a;
   assign wterms[1] = b;
   assign wterms[2] = c;

   genvar i;
   integer j;

   assign ci[0] = 1'b0;
   compressor_3_to_1_8bit_wide c3to1_8b_inst0(
      .a(wterms[0][7:0]),
      .b(wterms[1][7:0]),
      .c(wterms[2][7:0]),
      .c3to2_in(ci[0]),
      .ci(1'b0),
      .o(wo[7:0]),
      .co(co[0])
   );

   always_comb begin
      for (j=1;j<NUM_8BITS+1;j=j+1) begin
         ci[j] =   (wterms[0][j*8-1] & wterms[1][j*8-1])
                 | (wterms[0][j*8-1] & wterms[2][j*8-1])
                 | (wterms[1][j*8-1] & wterms[2][j*8-1]);
      end
   end

   generate   
      for (i=1;i<=NUM_8BITS;i=i+1) begin : c3to1s
         compressor_3_to_1_8bit_wide c3to1_8b_inst(
            .a(wterms[0][i*8+:8]),
            .b(wterms[1][i*8+:8]),
            .c(wterms[2][i*8+:8]),
            .c3to2_in(ci[i]),
            .ci(co[i-1]),
            .o(wo[i*8+:8]),
            .co(co[i])
         );
      end
   endgenerate

   assign o = wo[BIT_LEN+1:0];

endmodule


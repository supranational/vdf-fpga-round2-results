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
// modular_square_GGG_final
//
//  12/12/2019
//
//  by Kurt Baty
//

module modular_square_GGG_final
   #(
     parameter NUM_ELEMENTS = 21,
     parameter WORD_LEN     = 50,
     parameter ACC_BIT_LEN  = 58
   )
   (
     input  logic                   clk,
     input  logic                   ce,
     input  logic                   load_sq_in,
     input  logic [WORD_LEN:0]      sq_in[NUM_ELEMENTS],
     input  logic [ACC_BIT_LEN-1:0] acc_sum_terms[NUM_ELEMENTS],
     output logic [WORD_LEN:0]      sq_out[NUM_ELEMENTS]
   );

   localparam WIDTH_OF_TOP_REG = 33;
   genvar    e;

   logic [WIDTH_OF_TOP_REG-1:0] tmp_sq_out20;

   modular_square_GGG_final_muxaddreg #(
      .WORD_LEN(WORD_LEN),
      .ACC_BIT_LEN(ACC_BIT_LEN),
      .SQ_REG_LEN(WORD_LEN+1)
   )
   ms_GGG_fmxaddr_inst0 (
      .clk(clk),
      .ce(ce),
      .load_sq_in(load_sq_in),
      .sq_in(sq_in[0]),
      .acc_sum_term0(acc_sum_terms[0][WORD_LEN-1:0]),
      .acc_sum_term1({ACC_BIT_LEN-WORD_LEN{1'b0}}),
      .sq_out(sq_out[0]) 
   );

   generate 
      for (e=1;e<NUM_ELEMENTS-1;e++) begin : sq_ffs
         modular_square_GGG_final_muxaddreg #(
            .WORD_LEN(WORD_LEN),
            .ACC_BIT_LEN(ACC_BIT_LEN),
            .SQ_REG_LEN(WORD_LEN+1)
         )
         ms_GGG_fmxaddr (
            .clk(clk),
            .ce(ce),
            .load_sq_in(load_sq_in),
            .sq_in(sq_in[e]),
            .acc_sum_term0(acc_sum_terms[e][WORD_LEN-1:0]),
            .acc_sum_term1(acc_sum_terms[e-1][ACC_BIT_LEN-1:WORD_LEN]),
            .sq_out(sq_out[e])
         );
      end
   endgenerate   

   modular_square_GGG_final_muxaddreg #(
      .WORD_LEN(WORD_LEN),
      .ACC_BIT_LEN(ACC_BIT_LEN),
      .SQ_REG_LEN(WIDTH_OF_TOP_REG)
   )
   ms_GGG_fmxaddr_inst20 (
      .clk(clk),
      .ce(ce),
      .load_sq_in(load_sq_in),
      .sq_in(sq_in[20]),
      .acc_sum_term0(acc_sum_terms[20][WORD_LEN-1:0]),
      .acc_sum_term1(acc_sum_terms[19][ACC_BIT_LEN-1:WORD_LEN]),
      .sq_out(tmp_sq_out20)
   );

   always_comb begin
      sq_out[20] = {{WORD_LEN+1-WIDTH_OF_TOP_REG{1'b0}},tmp_sq_out20};
   end


endmodule


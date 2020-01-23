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
// modular_square_GGG_final_muxaddreg
//
//  12/12/2019
//
//  by Kurt Baty
//

module modular_square_GGG_final_muxaddreg
   #(
     parameter int WORD_LEN     = 50,
     parameter int ACC_BIT_LEN  = 58,
     parameter int SQ_REG_LEN   = 51
   )
   (
     input  logic                            clk,
     input  logic                            ce,
     input  logic                            load_sq_in,
     input  logic [WORD_LEN:0]               sq_in,
     input  logic [WORD_LEN-1:0]             acc_sum_term0,
     input  logic [ACC_BIT_LEN-WORD_LEN-1:0] acc_sum_term1,
     output logic [SQ_REG_LEN-1:0]           sq_out
   );


   logic [WORD_LEN:0] a,b,s;

   always_comb begin
      if ( load_sq_in ) begin
         a = sq_in;
         b = 'b0;
      end
      else begin
         a = acc_sum_term0;
         b = acc_sum_term1;
      end
      s = a + b;
   end

   always_ff @(posedge clk) begin
      if ( ce ) begin
         sq_out <= s[SQ_REG_LEN-1:0];
      end
   end


endmodule


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
// modulus_GGG_chunk_15b
//
//  10/7/2019
//  updated 12/11/2019
//
//  by Kurt Baty
//

module modulus_GGG_chunk_15b
   #(
     parameter MODULUS_WIDTH = 1024,
     parameter BIT_LEN       = 15,
     parameter CUR_LOW_POS   = MODULUS_WIDTH*2 - BIT_LEN
   )
   (
     input  logic                     clk_phase,
     input  logic                     ce,
     input  logic                     bypass,
     input  logic [BIT_LEN-1:0]       lut_addr,
     output logic [MODULUS_WIDTH-1:0] moduli_terms [3]
   );

   genvar    q;

   logic [BIT_LEN-1:0]  lut_addr_reg;
   logic [BIT_LEN-1:0]  lut_addr_mux;


   always @(posedge clk_phase) begin
      if ( ce ) begin
         lut_addr_reg <= lut_addr;
      end
   end

   assign lut_addr_mux = (bypass == 1)? lut_addr : lut_addr_reg;



   generate 
      for (q=0;q<3;q++) begin : quints
         modulus_quint #(
            .CUR_LOW_POS(CUR_LOW_POS+q*5),
            .MODULUS_WIDTH(MODULUS_WIDTH)
         )
         modulus_quint_inst (
            .in(lut_addr_mux[q*5+:5]),
            .mod_out(moduli_terms[q])
         );
      end
   endgenerate   


endmodule


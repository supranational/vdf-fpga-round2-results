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
// modulus_GGG_chunk_w_BRAMs
//
//  10/7/2019
//  updated 12/10/2019
//
//  by Kurt Baty
//

module modulus_GGG_chunk_w_BRAMs
   #(
     parameter MODULUS_WIDTH = 1024,
     parameter BIT_LEN       = 51,
     parameter CUR_LOW_POS   = MODULUS_WIDTH*2 - BIT_LEN
   )
   (
     input  logic                     clk_phase,
     input  logic                     ce,
     input  logic                     bypass,
     input  logic [BIT_LEN-1:0]       lut_addr,
     output logic [MODULUS_WIDTH-1:0] moduli_terms [7]
   );

   genvar    q,n;

   logic [3*5-1:0]  lut_addr_reg;
   logic [3*5-1:0]  lut_addr_mux;


   always @(posedge clk_phase) begin
      if ( ce ) begin
         lut_addr_reg <= lut_addr[3*5-1:0];
      end
   end

   assign lut_addr_mux = (bypass == 1)? lut_addr[3*5-1:0] : lut_addr_reg;


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

      for (n=0;n<4;n++) begin : nonuples
         modulus_nonuple #(
            .CUR_LOW_POS(CUR_LOW_POS+n*9+15),
            .MODULUS_WIDTH(MODULUS_WIDTH)
         )
         modulus_nonuple_inst (
            .clk_phase(clk_phase),
            .ce(ce),
            .in(lut_addr[n*9+15+:9]),
            .mod_out(moduli_terms[n+3])
         );
      end
   endgenerate


endmodule


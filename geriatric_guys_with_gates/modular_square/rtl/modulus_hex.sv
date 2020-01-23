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
//  modulus_hex
//
//  12/6/2019
//
//  by Kurt Baty
//

`include "msuconfig.vh"

(* keep_hierarchy = "yes" *)
module modulus_hex
   #(
     parameter MODULUS_WIDTH = 1024,
     parameter CUR_LOW_POS = 1024*2-6
   )
   (
    input  logic [5:0] in,
    output logic [MODULUS_WIDTH-1:0] mod_out
   );

   function [MODULUS_WIDTH-1:0] DO_MODULUS;
      input [5:0] X_VAL;
      begin
         reg [MODULUS_WIDTH*2+100:0] x_val_full_width;
         x_val_full_width = X_VAL;
         DO_MODULUS = (x_val_full_width << CUR_LOW_POS) % `MODULUS_DEF ;        
      end
   endfunction

`ifdef FASTSIM
   assign mod_out = DO_MODULUS(in);
`else

   integer    i;

   (* rom_style = "distributed" *) reg [MODULUS_WIDTH-1:0] hex_rom [64];
   initial begin
      for (i=0;i<64;i=i+1) begin
         hex_rom[ i] = DO_MODULUS( i);
      end
   end

   assign mod_out = hex_rom[in];

`endif

endmodule


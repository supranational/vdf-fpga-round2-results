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
// square_51
//
//  10/19/2019
//
//  by Kurt Baty
//

module square_51
   (
     input  logic [51-1  :0]   x,
     output logic [17*2*3-1:0] sq
   );

   localparam NUM_MULTS = 51 / 17;
   logic [17*2-1:0]   term_34w;
   logic [17*2*2-1:0] term_68w;
   logic [17*2*3-1:0] term_102w;
   logic [17*2*2:0]   term_69w;

   wire [51*2-1:0]  terms [NUM_MULTS];

   genvar    i,j,k;

   generate
      begin : multipliers
         for (i=0;i<NUM_MULTS;i=i+1) begin : part_selects_same
            mult_17x17 mult_inst (
               .x(x[17*i+:17]),
               .y(x[17*i+:17]),
               .p(term_102w[17*2*i+:17*2])
            );
         end

         for (j=1;j<NUM_MULTS;j=j+1) begin : part_selects_different
            for (k=0;k<(NUM_MULTS-j);k=k+1) begin : loop_k
               mult_17x17 mult_inst (
                  .x(x[17*(j+k)+:17]),
                  .y(x[17*k+:17]),
                  .p(terms[j][17*2*k+:17*2])
               );
            end
         end
      end
   endgenerate

   assign term_68w = terms[1][68-1:0];
   assign term_34w = terms[2][34-1:0];

   assign term_69w = term_68w + {term_34w,17'b0};
   assign sq       = term_102w + {term_69w,18'b0};


endmodule


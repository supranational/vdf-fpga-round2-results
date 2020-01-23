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
// compressor_3_to_1_tree_level
//
//  12/8/2019
//
//  by Kurt Baty
//

module compressor_3_to_1_tree_level
   #(
     parameter int NUM_ELEMENTS = 21,
     parameter int BIT_LEN      = 58,

     parameter int NUM_RESULTS  = integer'(NUM_ELEMENTS/3) + ((NUM_ELEMENTS%3 > 0)? 1 : 0)
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] results[NUM_RESULTS]
   );

   localparam NUM_3TO1 = integer'(NUM_ELEMENTS/3);
   logic [BIT_LEN+1:0]         local_results[NUM_RESULTS];
   genvar c;

   generate begin
      if ( ( NUM_ELEMENTS / 3 ) > 0 ) begin
         for (c=0;c<NUM_3TO1;c++) begin: c3to1s
            compressor_3_to_1 #(
               .BIT_LEN(BIT_LEN)
            )
            c3to1_inst(
               .a(terms[c*3]),
               .b(terms[c*3+1]),
               .c(terms[c*3+2]),
               .o(local_results[c])
            );
         end
      end
      if ( NUM_ELEMENTS % 3 == 2) begin: adder
         assign local_results[NUM_RESULTS-1] = terms[NUM_ELEMENTS-1] + terms[NUM_ELEMENTS-2];
      end
      else if ( NUM_ELEMENTS % 3 == 1 ) begin
         assign local_results[NUM_RESULTS-1] = terms[NUM_ELEMENTS-1];
      end
   end
   endgenerate

   always_comb begin
      for ( int i=0;i<NUM_RESULTS;i++) begin
         results[i] = local_results[i][BIT_LEN-1:0];
      end
   end

endmodule


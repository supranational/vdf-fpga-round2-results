/*******************************************************************************
  Copyright 2019 Eric Pearson

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

module adder_tree_2_to_1
   #(
     parameter int NUM_ELEMENTS      = 9,
     parameter int BIT_LEN           = 16
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] S
   );


   generate
      if (NUM_ELEMENTS == 1) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0];
         end
      end else if (NUM_ELEMENTS == 2) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0] + terms[1];
         end
      end else begin
         localparam integer NUM_RESULTS = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2);
         logic [BIT_LEN-1:0] next_level_terms[NUM_RESULTS];

         adder_tree_level #(.NUM_ELEMENTS(NUM_ELEMENTS),
                            .BIT_LEN(BIT_LEN)
         ) adder_tree_level (
                            .terms(terms),
                            .results(next_level_terms)
         );

         adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_RESULTS),
                                  .BIT_LEN(BIT_LEN)
         ) adder_tree_2_to_1 (
                                  .terms(next_level_terms),
                                  .S(S)
         );
      end
   endgenerate
endmodule

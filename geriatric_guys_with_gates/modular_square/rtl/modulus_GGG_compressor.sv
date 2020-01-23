/*******************************************************************************
  Copyright 2019 Eric Pearson
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

module modulus_GGG_compressor
   #(
     parameter int NUM_ELEMENTS      = 3+12*7+8*10+6, // 173
     parameter int BIT_LEN           = 58
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    input  logic [51-1:0]      extra_term,
    output logic [BIT_LEN-1:0] S
   );


   localparam integer NUM_RESULTS1 = integer'(NUM_ELEMENTS/3) + ((NUM_ELEMENTS%3 > 0)? 1 : 0);
   logic [BIT_LEN-1:0] next_level_terms1[NUM_RESULTS1];

   compressor_3_to_1_tree_level #(
      .NUM_ELEMENTS(NUM_ELEMENTS),
      .BIT_LEN(BIT_LEN)
   )
   c3to1_tl_inst (
      .terms(terms),
      .results(next_level_terms1)
   );


   localparam integer NUM_RESULTS2 = integer'(NUM_RESULTS1/2) + ((NUM_RESULTS1%2 > 0)? 1 : 0);
   logic [BIT_LEN-1:0] next_level_terms2[NUM_RESULTS2];

   adder_tree_level #(
      .NUM_ELEMENTS(NUM_RESULTS1),
      .BIT_LEN(BIT_LEN)
   )
   adder_tl_inst0 (
      .terms(next_level_terms1),
      .results(next_level_terms2)
   );


   localparam integer NUM_RESULTS3 = integer'(NUM_RESULTS2/2) + ((NUM_RESULTS2%2 > 0)? 1 : 0);
   logic [BIT_LEN-1:0] next_level_terms3[NUM_RESULTS3];

   adder_tree_level #(
      .NUM_ELEMENTS(NUM_RESULTS2),
      .BIT_LEN(BIT_LEN)
   )
   adder_tl_inst1 (
      .terms(next_level_terms2),
      .results(next_level_terms3)
   );


   integer             i;
   logic [BIT_LEN-1:0] last_level_terms[16];

   always_comb begin
      for (i=0;i<NUM_RESULTS3;i++) begin
         last_level_terms[i] = next_level_terms3[i];
      end
      last_level_terms[16-1] = extra_term;
   end

   adder_tree_2_to_1 #(
      .NUM_ELEMENTS(16),
      .BIT_LEN(BIT_LEN)
   ) 
   adder_tree_2_to_1 (
      .terms(last_level_terms),
      .S(S)
   );

endmodule


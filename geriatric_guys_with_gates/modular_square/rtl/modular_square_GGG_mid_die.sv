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

(* keep_hierarchy = "yes" *)
module modular_square_GGG_mid_die
   #(
     parameter int NONREDUNDANT_ELEMENTS = 21,
     parameter int NUM_SEGMENTS          = 1,
     parameter int BIT_LEN               = 51,
     parameter int WORD_LEN              = 50,

     parameter int REDUNDANT_ELEMENTS    = 0,
     parameter int NUM_ELEMENTS          = ( REDUNDANT_ELEMENTS + NONREDUNDANT_ELEMENTS ) // 21 words
    )
   (
    input logic                   clk_phase,
    input logic                   bypass,
    input logic [BIT_LEN-1:0]     sq_mid[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0]    low_grid_sum[NUM_ELEMENTS]
   );

   localparam int SEGMENT_ELEMENTS    = ( int'(NONREDUNDANT_ELEMENTS / NUM_SEGMENTS) ); // 21 elements of 51b for 1024 bits
   localparam int MUL_NUM_ELEMENTS    = ( REDUNDANT_ELEMENTS + SEGMENT_ELEMENTS );      // 21 elements of 51b to keep 1024 safely

   localparam int EXTRA_ELEMENTS      = 2;
   localparam int NUM_MULTIPLIERS     = 1;
   localparam int EXTRA_MUL_TREE_BITS = 6;  // 5 for CSA of 21 and 1 for 2x AB terms
   localparam int MUL_BIT_LEN         = ( ((BIT_LEN*2) - WORD_LEN) + EXTRA_MUL_TREE_BITS ); // 58b
   localparam int GRID_BIT_LEN        =  MUL_BIT_LEN; // 58b
   localparam int GRID_SIZE           = ( MUL_NUM_ELEMENTS*2 ); // 42 elements in a 2K word
   localparam int LOOK_UP_WIDTH       = 6;


   // Multiplier selects in/out and values
   logic [MUL_BIT_LEN-1:0]   mul_s[ GRID_SIZE ]; // 42 x 58b

   logic [GRID_BIT_LEN:0]    grid_sum[GRID_SIZE]; // 42 x 58b 
   logic [BIT_LEN-1:0]       reduced_grid_sum[GRID_SIZE]; // 42 x 58b
   logic [BIT_LEN-1:0]       reduced_grid_sum_reg[GRID_SIZE]; // 42 x 58b
 


   square_mid_die #(.NUM_ELEMENTS( 21 ),
              .BIT_LEN(    51 ),
              .WORD_LEN(   50 )
             )
      square_ (
                .A( sq_mid ),
                .S( mul_s )
               );

   // Carry propogate add each column in grid
   // Partially reduce adding neighbor carries
   always_comb begin
      for (int k=0; k<GRID_SIZE; k=k+1) begin
         grid_sum[k][GRID_BIT_LEN:0] = mul_s[k][GRID_BIT_LEN-1:0];
      end

      reduced_grid_sum[0] =    {{(BIT_LEN-WORD_LEN)                 {1'b0}}, grid_sum[0][WORD_LEN-1:0]};
      for (int k=1; k<GRID_SIZE-1; k=k+1) begin
         reduced_grid_sum[k]
            = {{(BIT_LEN-WORD_LEN)                 {1'b0}}, grid_sum[k  ][WORD_LEN-1:0]} +
              {{(BIT_LEN-(GRID_BIT_LEN-WORD_LEN))-1{1'b0}}, grid_sum[k-1][GRID_BIT_LEN:WORD_LEN]};
      end
      reduced_grid_sum[GRID_SIZE-1]
         = grid_sum[GRID_SIZE-1][BIT_LEN-1:0] +
           {{(BIT_LEN-(GRID_BIT_LEN-WORD_LEN))-1{1'b0}}, grid_sum[GRID_SIZE-2][GRID_BIT_LEN:WORD_LEN]};
   end
 
   always_ff @(posedge clk_phase)
      for (int k=0; k<NUM_ELEMENTS; k=k+1) begin
         reduced_grid_sum_reg[k] <= reduced_grid_sum[k];
      end

   // Set values for which segments to lookup in reduction LUTs
   always_comb begin
      if (bypass == 1) begin
         for (int k=0; k<NUM_ELEMENTS-1; k=k+1) begin
            low_grid_sum[k] = reduced_grid_sum[k];
         end
         low_grid_sum[NUM_ELEMENTS-1]
            = {{BIT_LEN-21{1'b0}},reduced_grid_sum[NUM_ELEMENTS-1][21-1:0]};
      end
      else begin
         for (int k=0; k<NUM_ELEMENTS-1; k=k+1) begin
            low_grid_sum[k] = reduced_grid_sum_reg[k];
         end
         low_grid_sum[NUM_ELEMENTS-1]
            = {{BIT_LEN-21{1'b0}},reduced_grid_sum_reg[NUM_ELEMENTS-1][21-1:0]};
      end
   end
   

endmodule


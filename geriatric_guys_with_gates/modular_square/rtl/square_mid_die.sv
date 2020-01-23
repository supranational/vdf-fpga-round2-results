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

module square_mid_die
   #(
     parameter int NUM_ELEMENTS    = 21,
     parameter int BIT_LEN         = 51,
     parameter int WORD_LEN        = 50,

     parameter int MUL_OUT_BIT_LEN  = (2*BIT_LEN),                       // 102b
     parameter int COL_BIT_LEN      = (MUL_OUT_BIT_LEN - WORD_LEN + 1),  // 53b include 1 for AB<<1
     parameter int EXTRA_TREE_BITS  = 5,                                 // 5 bits for sum of 21 max  
     parameter int OUT_BIT_LEN      = COL_BIT_LEN + EXTRA_TREE_BITS      // 58b is our per column data path width
    )
   (
    input  logic [BIT_LEN-1:0]         A[NUM_ELEMENTS],      // 21 x 51b
    output logic [OUT_BIT_LEN-1:0]     S[NUM_ELEMENTS*2]     // 42 x 58b
   );

   localparam int GRID_PAD_SHORT   = EXTRA_TREE_BITS;                             // +5b padding
   localparam int GRID_PAD_LONG    = (COL_BIT_LEN - WORD_LEN) + EXTRA_TREE_BITS;  // +8b padding

   logic [MUL_OUT_BIT_LEN-1:0] mul_result[NUM_ELEMENTS*NUM_ELEMENTS];  // 21*21 = 441 x 102b ( ~45K wires )
   logic [OUT_BIT_LEN-1:0]     grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];   // 42 rows of 42 columns x 58b ( ~102K wires! )

   // Instantiate the diagonal upper half of the multiplier array  ( only 1386 multipliers )
   genvar x, y;
   generate
      for (y=0; y<NUM_ELEMENTS; y=y+1) begin :Ys
         for (x=y; x<NUM_ELEMENTS; x=x+1) begin : Xs
            if ( y + x < 21 ) begin : yes 
               if ( x == y ) begin : use_square
                  square_51 squarer (
                     .x(A[x][BIT_LEN-1:0]),
                     .sq(mul_result[(NUM_ELEMENTS*y)+x])
                  );
               end
               else begin : use_mult
                  multiply_51x51 multiplier (
                     .a(A[x][BIT_LEN-1:0]),
                     .b(A[y][BIT_LEN-1:0]),
                     .p(mul_result[(NUM_ELEMENTS*y)+x])
                  );
               end
            end
         end
      end
   endgenerate

   int ii, jj;
   always_comb begin
      for (ii=0; ii<NUM_ELEMENTS*2; ii=ii+1) begin // Y
         for (jj=0; jj<NUM_ELEMENTS*2; jj=jj+1) begin // X
            grid[ii][jj] = 0;
         end
      end

      for (ii=0; ii<NUM_ELEMENTS; ii=ii+1) begin : grid_row // Y
         for (jj=ii; jj<NUM_ELEMENTS; jj=jj+1) begin : grid_col // X
            if( jj == ii ) begin // diagonal cases are used as is
                grid[(ii+jj)][(2*ii)]       = {{GRID_PAD_LONG{ 1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1       :0       ]};
                grid[(ii+jj+1)][((2*ii)+1)] = {{GRID_PAD_SHORT{1'b0}}, 1'b0, mul_result[(NUM_ELEMENTS*ii)+jj][MUL_OUT_BIT_LEN-1:WORD_LEN]};
            end else begin // all non diagonal cases are doubled
                grid[(ii+jj)][(2*ii)]       = {{GRID_PAD_LONG{ 1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-2       :0         ], 1'b0};
                grid[(ii+jj+1)][((2*ii)+1)] = {{GRID_PAD_SHORT{1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][MUL_OUT_BIT_LEN-1:WORD_LEN-1]};
            end
            
         end
      end
   end

   // Sum each column using compressor tree
   integer  n;
   genvar   i;
   generate
      // The first and last columns
      always_comb begin
         S[0][OUT_BIT_LEN-1:0]                  = grid[0][0][OUT_BIT_LEN-1:0];
         for (n=21; n<(NUM_ELEMENTS*2); n=n+1) begin
            S[n] = 'b0;
         end
      end

      for (i=1; i<21; i=i+1) begin : col_sums
         localparam integer CUR_ELEMENTS = (i <  NUM_ELEMENTS) ? (i+1) : NUM_ELEMENTS*2 - i;
         localparam integer GRID_INDEX   = (i <  NUM_ELEMENTS) ? 0 : ((i - NUM_ELEMENTS)*2+1);

        adder_tree_2_to_1 #(.NUM_ELEMENTS(CUR_ELEMENTS),
                                  .BIT_LEN(OUT_BIT_LEN)
                                 )
            adder_tree_2_to_1 (
               .terms(grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)]),
               .S(S[i])
            );

      end
   endgenerate
endmodule

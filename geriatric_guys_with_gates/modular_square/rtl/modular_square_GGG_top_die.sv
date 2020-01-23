/*******************************************************************************
  Copyright 2019 Eric Pearson
  Copyright 2019 Kurt Baty
  Copyright 2019 Steve Golson

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
module modular_square_GGG_top_die
   #(
     parameter int REDUNDANT_ELEMENTS    = 0,
     parameter int NONREDUNDANT_ELEMENTS = 21,
     parameter int NUM_SEGMENTS          = 1,
     parameter int BIT_LEN               = 51,
     parameter int WORD_LEN              = 50,

     parameter int NUM_ELEMENTS          = ( REDUNDANT_ELEMENTS + NONREDUNDANT_ELEMENTS ) // 21 words
    )
   (
    input logic [3:0]             clk_phase,
    input logic                   reset,
    input logic                   start,
    input logic [NUM_ELEMENTS:0]  bypass,
    input logic [BIT_LEN-1:0]     sq_in[NUM_ELEMENTS],
    input logic [BIT_LEN-1:0]     low_grid_sum[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0]    sq_out[NUM_ELEMENTS],
    output logic                  valid,
    output logic                  valid_toggle
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

   localparam int ACC_NUM_ELEMENTS    = 22;     // 22    lookup address sets 
   localparam int ACC_ELEMENTS        = 3+12*7+8*10+6;  // 173 lookup data rows 
   localparam int ACC_EXTRA_ELEMENTS  = 1; // Addin the lower bits of the product
   localparam int ACC_EXTRA_BIT_LEN   = 8; // WAS: $clog2(ACC_ELEMENTS+ACC_EXTRA_ELEMENTS);
   localparam int ACC_BIT_LEN         = ( WORD_LEN + ACC_EXTRA_BIT_LEN ); // 58b

   // Multiplier selects in/out and values
   logic [MUL_BIT_LEN-1:0]   mul_s[ GRID_SIZE ]; // 42 x 58b

   logic [GRID_BIT_LEN:0]    grid_sum[GRID_SIZE]; // 42 x 58b 
   logic [BIT_LEN-1:0]       reduced_grid_sum[GRID_SIZE]; // 42 x 58b
   logic [BIT_LEN-1:0]       reduced_grid_sum_reg[GRID_SIZE]; // 42 x 58b
 

   logic [BIT_LEN-1:0]       lut_addrs[ACC_NUM_ELEMENTS]; // 22 x 51b lookup addresses
   logic [WORD_LEN-1:0]      lut_datas[NUM_ELEMENTS][ACC_ELEMENTS]; // 22 words 220 lookup values

   logic [ACC_BIT_LEN-1:0]   acc_stack[NUM_ELEMENTS][ACC_ELEMENTS];
   logic [ACC_BIT_LEN-1:0]   acc_sum[NUM_ELEMENTS]; //  column sums of 58b

   logic                     running;
   logic 		     load_sq_in;

   assign load_sq_in = start || reset;

   always @ (posedge clk_phase[0]) begin
      if (reset) begin
	 running <= 1'b0;
	 valid <= 1'b0;
	 valid_toggle <= 1'b0;
      end
      else if (start) begin
	 running <= 1'b1;
	 valid <= 1'b0;
      end
      else if (running) begin
	 valid <= 1'b1;
	 valid_toggle <= !valid_toggle;
      end
   end

   square_top_die #(.NUM_ELEMENTS( 21 ),
              .BIT_LEN(    51 ),
              .WORD_LEN(   50 )
             )
      square_ (
                .A( sq_out ),
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
         reduced_grid_sum[k] = {{(BIT_LEN-WORD_LEN)                 {1'b0}}, grid_sum[k  ][WORD_LEN-1:0]} +
                               {{(BIT_LEN-(GRID_BIT_LEN-WORD_LEN))-1{1'b0}}, grid_sum[k-1][GRID_BIT_LEN:WORD_LEN]};
      end
      reduced_grid_sum[GRID_SIZE-1] = grid_sum[GRID_SIZE-1][BIT_LEN-1:0] +
                               {{(BIT_LEN-(GRID_BIT_LEN-WORD_LEN))-1{1'b0}}, grid_sum[GRID_SIZE-2][GRID_BIT_LEN:WORD_LEN]};
   end
 
   // Set values for which segments to lookup in reduction LUTs
   always_comb begin
      for (int k=0; k<ACC_NUM_ELEMENTS; k=k+1) begin
         lut_addrs[k] = reduced_grid_sum[k+20];
      end
   end
   

   // Instantiate memory holding reduction LUTs
   modulus_GGG modulus_GGG_inst (
      .clk_phase( clk_phase[3:1] ), // brams must be clocked, but not lutrams :)
      .ce( 1'b1 ), // enable Lut regs
      .bypass(bypass),
      .lut_addrs(lut_addrs),
      .lut_datas(lut_datas)
   );


   always_comb begin
      // zero acc array   
      for (int k=0; k<NUM_ELEMENTS; k=k+1) begin
         for (int j=0; j<ACC_ELEMENTS; j=j+1) begin
            acc_stack[k][j][ACC_BIT_LEN-1:0] = 0;
         end
      end
      for (int k=0; k<NUM_ELEMENTS; k=k+1) begin
         for (int j=0; j<ACC_ELEMENTS; j=j+1) begin
            acc_stack[k][j+  0][ACC_BIT_LEN-1:0] = {{(ACC_EXTRA_BIT_LEN){1'b0}}, lut_datas[k][j][WORD_LEN-1:0]};
         end
      end
   end


   // Instantiate compressor trees to accumulate over accumulator columns

   genvar     i;
   
   generate
      for (i=0; i<NUM_ELEMENTS; i=i+1) begin : final_acc
         modulus_GGG_compressor compressor_inst (
            .terms(acc_stack[i]),
            .extra_term(low_grid_sum[i]),
            .S(acc_sum[i])
         );
      end
   endgenerate

   modular_square_GGG_final ms_GGG_fmxaddr_inst0 (
      .clk(clk_phase[0]),
      .ce( 1'b1 ),
      .load_sq_in(load_sq_in),
      .sq_in(sq_in),
      .acc_sum_terms(acc_sum),
      .sq_out(sq_out)
   );


endmodule


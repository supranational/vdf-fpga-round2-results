/*******************************************************************************
  Copyright 2019 Eric Pearson
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

`ifndef MOD_LEN_DEF
`define MOD_LEN_DEF 1024
`endif

module modular_square_wrapper
   #(
     parameter int MOD_LEN               = `MOD_LEN_DEF,

     parameter int WORD_LEN              = 50,
     parameter int REDUNDANT_ELEMENTS    = 0,
     parameter int NONREDUNDANT_ELEMENTS = 21,
     parameter int NUM_ELEMENTS          = REDUNDANT_ELEMENTS +
                                           NONREDUNDANT_ELEMENTS,
     parameter int SQ_OUT_BITS           = NUM_ELEMENTS * (WORD_LEN+1)
    )
   (
    input logic                    clk,
    input logic                    reset,
    input logic                    start,
    input logic                    start_toggle,
    input logic [MOD_LEN-1:0]      sq_in,
    output logic [SQ_OUT_BITS-1:0] sq_out,
    output logic                   valid
   );

   localparam int BIT_LEN               = 51;

   logic [BIT_LEN-1:0] sq_in_stages[NUM_ELEMENTS];
   logic [BIT_LEN-1:0] sq_out_stages[NUM_ELEMENTS];

   logic mmcm_fb;
   logic [15:0] modsqr_clk_phase;
   logic [22:0] modsqr_bypass;

   logic 	modsqr_reset;

   logic modsqr_start_pipe3;
   logic modsqr_start;

   logic valid_pipe3;
   logic modsqr_valid, modsqr_valid_toggle;
      
   genvar              j;

   // Split sq_in into polynomial coefficients
    generate
      for(j = 0; j < NONREDUNDANT_ELEMENTS-1; j++) begin
	 always_comb begin
            sq_in_stages[j] = {{(BIT_LEN-WORD_LEN){1'b0}},
                               sq_in[j*WORD_LEN +: WORD_LEN]};
	 end
      end
   endgenerate
   always_comb begin
     sq_in_stages[NONREDUNDANT_ELEMENTS-1] = sq_in[MOD_LEN-1:1000];
   end

   // Gather the output coefficients into sq_out
   generate
      for(j = 0; j < NUM_ELEMENTS; j++) begin
         always_comb begin
            sq_out[j*BIT_LEN +: BIT_LEN] = sq_out_stages[j];
         end
      end
   endgenerate

   modular_square_GGG_coeff51 modsqr(
          .clk_phase          ( modsqr_clk_phase ),
          .reset              ( modsqr_reset ),
          .bypass             ( modsqr_bypass ),
          .start              ( modsqr_start ),
          .sq_in              ( sq_in_stages ),
          .sq_out             ( sq_out_stages ),
          .valid              ( modsqr_valid ),
          .valid_toggle       ( modsqr_valid_toggle )
          );

   //// Reset CDC ////
   (* ASYNC_REG = "TRUE" *) reg modsqr_reset_sync1, modsqr_reset_sync2;
   always_ff @(posedge modsqr_clk_phase[0]) begin
      modsqr_reset_sync1 <= reset;
      modsqr_reset_sync2 <= modsqr_reset_sync1;
   end
   assign modsqr_reset = modsqr_reset_sync2;

   ///// Start CDC ////
   (* ASYNC_REG = "TRUE" *) reg modsqr_start_sync1, modsqr_start_sync2;
   always_ff @(posedge modsqr_clk_phase[0]) begin
      modsqr_start_sync1 <= start_toggle;
      modsqr_start_sync2 <= modsqr_start_sync1;
      modsqr_start_pipe3 <= modsqr_start_sync2;
   end
   assign modsqr_start = modsqr_start_sync2 ^ modsqr_start_pipe3;
   
   ///// Valid CDC //////
   (* ASYNC_REG = "TRUE" *) reg valid_sync1, valid_sync2;
   always_ff @(posedge clk) begin
      valid_sync1 <= modsqr_valid_toggle;
      valid_sync2 <= valid_sync1;
      valid_pipe3 <= valid_sync2;
   end
   assign valid = valid_sync2 ^ valid_pipe3;

   // bypass flops
   // eventually these may be under software control
   // these always drive 1, which causes chunk addr regs to be bypassed
   // but during synth/impl we can set_case_analysis to 0
   // to reduce the number of timing paths
   (* DONT_TOUCH = "TRUE" *) FDCE #(
      .INIT(1'b1)		// initialize to 1
   ) bypass_reg[22:0] (
      .Q(modsqr_bypass[22:0]),
      .C(modsqr_clk_phase[0]),
      .CE(1'b1),		// always enable
      .CLR(1'b0),		// never clear
      .D(1'b1)			// always load 1
   );

   ///// PLL /////////

   MMCME4_BASE #(
		 .CLKIN1_PERIOD    ( 8.000 ),   // 125 MHz
		 .DIVCLK_DIVIDE    (  3    ),   // 41.667 MHz at input to phase detect
		 .CLKFBOUT_MULT_F  ( 31    ),   // 1291.667 MHz VCO
		 .CLKFBOUT_PHASE(0.0),       

		 .CLKOUT0_DIVIDE_F ( 33    ),   // 39.141 MHz = 25.548 ns
		 .CLKOUT0_DUTY_CYCLE(0.5),      // clk_phase[8] @ 12.774 ns
		 .CLKOUT0_PHASE(0.0),        

		 .CLKOUT1_DIVIDE   ( 33    ),   // 39.141 MHz = 25.548 ns
`ifdef XILINX_SIMULATOR
		 .CLKOUT1_DUTY_CYCLE(0.50),     // clk_phase[1] using value that simulation model supports
`else
		 .CLKOUT1_DUTY_CYCLE(0.407),    // clk_phase[1] @ 10.398 ns
`endif
		 .CLKOUT1_PHASE(0.0),        

		 .CLKOUT2_DIVIDE   ( 33    ),   // 39.141 MHz = 25.548 ns
`ifdef XILINX_SIMULATOR
		 .CLKOUT2_DUTY_CYCLE(0.50),     // clk_phase[2] using value that simulation model supports
`else
		 .CLKOUT2_DUTY_CYCLE(0.430),    // clk_phase[2] @ 10.986 ns
`endif
		 .CLKOUT2_PHASE(0.0),        

		 .CLKOUT3_DIVIDE   ( 33     ),  // 39.141 MHz = 25.548 ns
`ifdef XILINX_SIMULATOR
		 .CLKOUT3_DUTY_CYCLE(0.50),     // clk_phase[3] using value that simulation model supports
`else
		 .CLKOUT3_DUTY_CYCLE(0.398),    // clk_phase[3] @ 10.168 ns
`endif
		 .CLKOUT3_PHASE(0.0),        

		 .CLKOUT4_DIVIDE   ( 20     ),
		 .CLKOUT4_DUTY_CYCLE(0.5),   
		 .CLKOUT4_PHASE(0.0),        

		 .CLKOUT5_DIVIDE   ( 20     ),
		 .CLKOUT5_DUTY_CYCLE(0.5),   
		 .CLKOUT5_PHASE(0.0),        

		 .CLKOUT6_DIVIDE   ( 20     ),
		 .CLKOUT6_DUTY_CYCLE(0.5),   
		 .CLKOUT6_PHASE(0.0),        

		 .BANDWIDTH("OPTIMIZED"),   
		 .CLKOUT4_CASCADE("FALSE"),  
		 .IS_CLKFBIN_INVERTED(1'b0), 
		 .IS_CLKIN1_INVERTED(1'b0),  
		 .IS_PWRDWN_INVERTED(1'b0),  
		 .IS_RST_INVERTED(1'b0),     
		 .REF_JITTER1(0.010),        
		 .STARTUP_WAIT("TRUE")       
		 )
   MMCME4_inst_ (
		 .CLKIN1   ( clk       ),                 
		 .CLKFBIN  ( mmcm_fb   ),        
		 .CLKFBOUT ( mmcm_fb   ),            

		 .CLKOUT0  ( modsqr_clk_phase[0] ),
		 .CLKOUT1  ( ),
		 .CLKOUT2  ( ),
		 .CLKOUT3  ( ),
		 .CLKOUT0B ( modsqr_clk_phase[8] ),
		 .CLKOUT1B ( modsqr_clk_phase[1] ),
		 .CLKOUT2B ( modsqr_clk_phase[2] ),
		 .CLKOUT3B ( modsqr_clk_phase[3] ),

		 .CLKOUT4  ( ),  
		 .CLKOUT5  ( ),            
		 .CLKOUT6  ( ),  
		 .CLKFBOUTB( ),                     
		 .LOCKED   (   ),                        
		 .PWRDWN   ( 1'b0 ),                    
		 .RST      ( 1'b0 )          
		 );

endmodule

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

module modular_square_GGG_coeff51
   #(
     parameter int REDUNDANT_ELEMENTS    = 0,
     parameter int NONREDUNDANT_ELEMENTS = 21,
     parameter int BIT_LEN               = 51,
     parameter int WORD_LEN              = 50,

     parameter int NUM_ELEMENTS          = ( REDUNDANT_ELEMENTS + NONREDUNDANT_ELEMENTS ) // 21 words
    )
   (
    input logic [15:0]            clk_phase,
    input logic                   reset,
    input logic                   start,
    input logic [23-1:0]          bypass,
    input logic [BIT_LEN-1:0]     sq_in[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0]    sq_out[NUM_ELEMENTS],
    output logic                  valid,
    output logic                  valid_toggle
   );

   logic [BIT_LEN-1:0]       low_grid_sum[NUM_ELEMENTS];
   logic [3:0]               clk_phase_top_die;


   assign clk_phase_top_die = clk_phase[3:0];

   modular_square_GGG_top_die modsqr_topdie(
      .clk_phase          ( clk_phase_top_die ),
      .reset              ( reset ),
      .start              ( start ),
      .bypass             ( bypass[22-1:0] ),
      .sq_in              ( sq_in ),
      .low_grid_sum       ( low_grid_sum ),
      .sq_out             ( sq_out ),
      .valid              ( valid ),
      .valid_toggle       ( valid_toggle )
   );

   modular_square_GGG_mid_die modsqr_middie(
      .clk_phase          ( clk_phase[8] ), // 50% !clk
      .bypass             ( bypass[23-1] ),
      .sq_mid             ( sq_out ),
      .low_grid_sum       ( low_grid_sum )
   );


endmodule


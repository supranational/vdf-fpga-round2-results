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
// modulus_GGG
//
//  11/15/2019
//  updated 12/11/2019
//
//  by Kurt Baty
//

module modulus_GGG
   #(
     parameter int BIT_LEN                   = 51,
     parameter int NUM_ELEMENTS              = 21,
     parameter int ACC_NUM_ELEMENTS          = NUM_ELEMENTS + 1,
     parameter int ACC_ELEMENTS              = 6 + 12*7 + 8*10 + 3
   )
   (
     input  logic [3:1]                  clk_phase,
     input  logic                        ce,
     input  logic [ACC_NUM_ELEMENTS-1:0] bypass,
     input  logic [BIT_LEN-1:0]          lut_addrs[ACC_NUM_ELEMENTS],
     output logic [BIT_LEN-2:0]          lut_datas[NUM_ELEMENTS][ACC_ELEMENTS]
   );

   localparam NUM_CHUNKS        = ACC_NUM_ELEMENTS;
   localparam MODULUS_WIDTH     = 1024;
   localparam WORD_LEN          = BIT_LEN-1;
   localparam TERMS_IN_A_CHUNK0 = 6;
   localparam TERMS_IN_A_CHUNK1 = 10;
   localparam TERMS_IN_A_CHUNK2 = 7;
   localparam TERMS_IN_A_CHUNK3 = 3;
   
   logic [MODULUS_WIDTH-1:0] moduli_terms0 [TERMS_IN_A_CHUNK0];
   logic [MODULUS_WIDTH-1:0] moduli_terms1 [8][TERMS_IN_A_CHUNK1];
   logic [MODULUS_WIDTH-1:0] moduli_terms2 [12][TERMS_IN_A_CHUNK2];
   logic [MODULUS_WIDTH-1:0] moduli_terms3 [TERMS_IN_A_CHUNK3];

   logic [NUM_CHUNKS-1:0]    clk_phase_to_chunk;

   integer   i,j,k;

   genvar    c,d;

   assign clk_phase_to_chunk = {{6{clk_phase[1]}},{7{clk_phase[2]}},{9{clk_phase[3]}}}; 

   modulus_GGG_chunk_30b #(
      .CUR_LOW_POS(20*WORD_LEN+21)
   )
   modulus_GGG_chunk_30b_inst0 (
      .clk_phase(clk_phase_to_chunk[0]),
      .ce(ce),
      .bypass(bypass[0]),
      .lut_addr(lut_addrs[0][BIT_LEN-1:21]),
      .moduli_terms(moduli_terms0)
   );

   generate 
      for (c=0;c<8;c=c+1) begin : chunks1
         modulus_GGG_chunk #(
            .CUR_LOW_POS(21*WORD_LEN+WORD_LEN*c)
         )
         modulus_GGG_chunk_inst (
            .clk_phase(clk_phase_to_chunk[1+c]),
            .ce(ce),
            .bypass(bypass[1+c]),
            .lut_addr(lut_addrs[c+1]),
            .moduli_terms(moduli_terms1[c])
         );
      end
   endgenerate   

   generate 
      for (d=0;d<12;d=d+1) begin : chunks2
         modulus_GGG_chunk_w_BRAMs #(
            .CUR_LOW_POS(29*WORD_LEN+WORD_LEN*d)
         )
         modulus_GGG_chunk_w_BRAM_inst (
            .clk_phase(clk_phase_to_chunk[1+8+d]),
            .ce(ce),
            .bypass(bypass[1+8+d]),
            .lut_addr(lut_addrs[1+8+d]),
            .moduli_terms(moduli_terms2[d])
         );
      end
   endgenerate   

   modulus_GGG_chunk_15b #(
      .CUR_LOW_POS(41*WORD_LEN)
   )
   modulus_GGG_chunk_inst_21 (
      .clk_phase(clk_phase_to_chunk[NUM_CHUNKS-1]),
      .ce(ce),
      .bypass(bypass[NUM_CHUNKS-1]),
      .lut_addr(lut_addrs[NUM_CHUNKS-1][15-1:0]),
      .moduli_terms(moduli_terms3)
   );


   always_comb begin
      for (j=0;j<TERMS_IN_A_CHUNK0;j++) begin
         for (k=0;k<NUM_ELEMENTS-1;k++) begin
            lut_datas[k][j]
               = moduli_terms0[j][k*WORD_LEN+:WORD_LEN];
         end
         lut_datas[NUM_ELEMENTS-1][j]
            =  moduli_terms0[j][MODULUS_WIDTH-1:(NUM_ELEMENTS-1)*WORD_LEN];
      end
      for (i=0;i<8;i++) begin
         for (j=0;j<TERMS_IN_A_CHUNK1;j++) begin
            for (k=0;k<NUM_ELEMENTS-1;k++) begin
               lut_datas[k][i*TERMS_IN_A_CHUNK1+TERMS_IN_A_CHUNK0+j]
                  = moduli_terms1[i][j][k*WORD_LEN+:WORD_LEN];
            end
            lut_datas[NUM_ELEMENTS-1][i*TERMS_IN_A_CHUNK1+TERMS_IN_A_CHUNK0+j]
               =  moduli_terms1[i][j][MODULUS_WIDTH-1:(NUM_ELEMENTS-1)*WORD_LEN];
         end
      end
      for (i=0;i<12;i++) begin
         for (j=0;j<TERMS_IN_A_CHUNK2;j++) begin
            for (k=0;k<NUM_ELEMENTS-1;k++) begin
               lut_datas[k][i*TERMS_IN_A_CHUNK2+86+j]
                  = moduli_terms2[i][j][k*WORD_LEN+:WORD_LEN];
            end
            lut_datas[NUM_ELEMENTS-1][i*TERMS_IN_A_CHUNK2+86+j]
               =  moduli_terms2[i][j][MODULUS_WIDTH-1:(NUM_ELEMENTS-1)*WORD_LEN];
         end
      end
      for (j=0;j<TERMS_IN_A_CHUNK3;j++) begin
         for (k=0;k<NUM_ELEMENTS-1;k++) begin
            lut_datas[k][170+j]
               = moduli_terms3[j][k*WORD_LEN+:WORD_LEN];
         end
         lut_datas[NUM_ELEMENTS-1][170+j]
            =  moduli_terms3[j][MODULUS_WIDTH-1:(NUM_ELEMENTS-1)*WORD_LEN];
      end
   end
            
endmodule


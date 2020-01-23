#
#  Copyright 2019 Supranational, LLC
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

############################################################################
# Multiplier configuration
############################################################################

SIMPLE_SQ             ?= 0
MOD_LEN               ?= 1024

# 1 - Connect the testbench directly to the squaring circuit
# 0 - Connect the testbench directly to the MSU
DIRECT_TB             ?= 0

# Constants for the Ozturk multiplier
REDUNDANT_ELEMENTS     = 0
NONREDUNDANT_ELEMENTS ?= 21
NUM_ELEMENTS           = $(shell expr $(NONREDUNDANT_ELEMENTS) \+ \
	                              $(REDUNDANT_ELEMENTS))
WORD_LEN               = 50
BIT_LEN                = 51

SQ_IN_BITS             = $(MOD_LEN)
SQ_OUT_BITS            = $(shell expr $(NUM_ELEMENTS) \* $(BIT_LEN))

MODULUS = 124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331

# Configure MSU parameters. These are included through vdf_kernel.sv
msuconfig.vh:
	echo "\`define SQ_IN_BITS_DEF $(SQ_IN_BITS)" \
              > msuconfig.vh
	echo "\`define SQ_OUT_BITS_DEF $(SQ_OUT_BITS)" \
              >> msuconfig.vh
	echo "\`define MODULUS_DEF $(MOD_LEN)'d$(MODULUS)" \
              >> msuconfig.vh
	echo "\`define MOD_LEN_DEF $(MOD_LEN)" \
              >> msuconfig.vh
ifeq ($(SIMPLE_SQ), 1)
	echo "\`define SIMPLE_SQ $(SIMPLE_SQ)" \
              >> msuconfig.vh
endif

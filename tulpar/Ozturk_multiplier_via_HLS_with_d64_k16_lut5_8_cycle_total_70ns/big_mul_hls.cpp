#include <stdint.h>
#include "ap_int.h"

#include "lut51_d64_k16.h"
#include "lut52_d64_k16.h"
#include "lut53_d64_k16.h"
#include "lut54_d64_k16.h"
#include "lut55_d64_k16.h"
#include "lut56_d64_k16.h"
#include "lut57_d64_k16.h"
#include "lut58_d64_k16.h"
#include "lut59_d64_k16.h"
#include "lut5A_d64_k16.h"
#include "lut5B_d64_k16.h"
#include "lut5C_d64_k16.h"
#include "lut5D_d64_k16.h"

#include <iostream>
using namespace std;

#define n 1024
#define d 64
#define k 16
#define log2kp3 6

typedef unsigned __int128 uint128_t;

void mulhilo(ap_uint<65> x, ap_uint<65> y, ap_uint<64> *hi, ap_uint<64> *lo, ap_uint<2> *redundant){ // x width d+1, y width d+1, hi width d, lo width d,
    ap_uint<130> res = (ap_uint<130>) x * (ap_uint<130>) y; // width 2*d+2
    *lo = res;
    *hi = res >> d;
    *redundant = res >> 2*d;
}



//Algorithm  7 and 9 Final Redundant-Representation PolynomialMultiplication Algorithm with final Reduction
void big_mul(ap_uint<(65)> z[k+1], ap_uint<(65)> x[k+1], ap_uint<(65)> y[k+1]/*, ap_uint<16> LUT[19][131072][16]*/){

//#pragma HLS INTERFACE s_axilite port=return bundle=ISAN
//#pragma HLS INTERFACE s_axilite register port=z bundle=ISAN
//#pragma HLS INTERFACE s_axilite port=x bundle=ISAN
//#pragma HLS INTERFACE s_axilite port=y bundle=ISAN

#pragma HLS ARRAY_RESHAPE variable=x complete dim=1
#pragma HLS ARRAY_RESHAPE variable=y complete dim=1
#pragma HLS ARRAY_RESHAPE variable=z complete dim=1


#pragma HLS RESOURCE variable=LUT51 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT52 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT53 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT54 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT55 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT56 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT57 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT58 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT59 core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT5A core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT5B core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT5C core=ROM_nP_LUTRAM latency=0
#pragma HLS RESOURCE variable=LUT5D core=ROM_nP_LUTRAM latency=0

    int i, j, l;

  /*
   for(int i=0;i<17;i++){
	   //printf("z[%d]:%0.16x\n",i,(unsigned )z[i]);
	   //printf("z[%d]:%0.16x\n", i, z[i]);
	   std::cout << "big_mul z[" << int(i) << "]:" << std::hex << z[i] << endl;
   }
    for(int i=0;i<17;i++){
	   //printf("z[%d]:%0.16x\n",i,(unsigned )z[i]);
	   //printf("z[%d]:%0.16x\n", i, z[i]);
	   std::cout << "big_mul x[" << int(i) << "]:" << std::hex << x[i] << endl;
   }
   for(int i=0;i<17;i++){
	   //printf("z[%d]:%0.16x\n",i,(unsigned )z[i]);
	   //printf("z[%d]:%0.16x\n", i, z[i]);
	   std::cout << "big_mul y[" << int(i) << "]:" << std::hex << y[i] << endl;
   }*/

#pragma HLS pipeline II=8
#pragma HLS LATENCY max=8 min=8

    ap_uint<128> D[2*k+3]; // width 2*d
#pragma HLS ARRAY_RESHAPE variable=D complete dim=1

    ap_uint<128> C[2*k+3]; // width d+log2kp3
#pragma HLS ARRAY_RESHAPE variable=C complete dim=1

     for(i=0; i<2*k+3; i++){
#pragma HLS UNROLL factor=35//2*k+3
    	D[i]=0;
    }

     for(i=0; i<2*k+3; i++){
#pragma HLS UNROLL factor=35//2*k+3
    	C[i]=0;
    }


    for(i=0; i<k+1; i++){
#pragma HLS UNROLL factor=17//k+1
        for(j=0; j<k+1; j++){
#pragma HLS UNROLL factor=17//k+1

            int ipj = i + j;
            ap_uint<64> lo[(k+1)*(k+1)], hi[(k+1)*(k+1)];
            ap_uint<2> redundant[(k+1)*(k+1)];
            mulhilo(x[i], y[j], &hi[i*(k+1)+j], &lo[i*(k+1)+j], &redundant[i*(k+1)+j]);
            D[ipj] = D[ipj] + lo[i*(k+1)+j];
            D[ipj+1] = D[ipj+1] + hi[i*(k+1)+j];
            D[ipj+2] = D[ipj+2] + redundant[i*(k+1)+j];
        }
    }

    C[2*k+2]=D[2*k+2];

    for(i=0; i<2*k+2; i++){
#pragma HLS UNROLL factor=34//2*k+2
    	C[i]=C[i]+(D[i]&(0xFFFFFFFFFFFFFFFF));
    	C[i+1]=C[i+1]+(D[i]>>64);
    }

     for(i=0; i<k; i++){
#pragma HLS UNROLL factor=16//k-1
    	D[i]=C[i];
    }

     for(i=k; i<2*k+3; i++){
#pragma HLS UNROLL factor=35//2*k+3
    	 for(j=0; j<k; j++){
#pragma HLS UNROLL factor=16//k
	   D[j]=D[j]+LUT51[i-k][j][(ap_uint<5>)(C[i]&0x1F)];
	   D[j]=D[j]+LUT52[i-k][j][(ap_uint<5>)((C[i]>>5)&0x1F)];
	   D[j]=D[j]+LUT53[i-k][j][(ap_uint<5>)((C[i]>>10)&0x1F)];
	   D[j]=D[j]+LUT54[i-k][j][(ap_uint<5>)((C[i]>>15)&0x1F)];
	   D[j]=D[j]+LUT55[i-k][j][(ap_uint<5>)((C[i]>>20)&0x1F)];
	   D[j]=D[j]+LUT56[i-k][j][(ap_uint<5>)((C[i]>>25)&0x1F)];
	   D[j]=D[j]+LUT57[i-k][j][(ap_uint<5>)((C[i]>>30)&0x1F)];
	   D[j]=D[j]+LUT58[i-k][j][(ap_uint<5>)((C[i]>>35)&0x1F)];
	   D[j]=D[j]+LUT59[i-k][j][(ap_uint<5>)((C[i]>>40)&0x1F)];
	   D[j]=D[j]+LUT5A[i-k][j][(ap_uint<5>)((C[i]>>45)&0x1F)];
	   D[j]=D[j]+LUT5B[i-k][j][(ap_uint<5>)((C[i]>>50)&0x1F)];
	   D[j]=D[j]+LUT5C[i-k][j][(ap_uint<5>)((C[i]>>55)&0x1F)];
	   D[j]=D[j]+LUT5D[i-k][j][(ap_uint<5>)((C[i]>>60)&0x1F)];
		}
    }

     for(i=0; i<k; i++){
#pragma HLS UNROLL factor=16//k
    	z[i]=z[i]+(D[i]&(0xFFFFFFFFFFFFFFFF));//0xFFFF);
    	z[i+1]=z[i+1]+(D[i]>>64);//>>16);
    }

}

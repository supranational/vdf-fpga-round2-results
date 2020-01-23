#include <stdint.h>
#include "ap_int.h"

#include "lut21_d32_k32.h"
#include "lut22_d32_k32.h"
#include "lut23_d32_k32.h"
#include "lut24_d32_k32.h"
#include "lut25_d32_k32.h"
#include "lut26_d32_k32.h"
#include "lut27_d32_k32.h"
#include "lut28_d32_k32.h"
#include "lut29_d32_k32.h"
#include "lut2A_d32_k32.h"
#include "lut2B_d32_k32.h"
#include "lut2C_d32_k32.h"
#include "lut2D_d32_k32.h"
#include "lut2E_d32_k32.h"
#include "lut2F_d32_k32.h"
#include "lut210_d32_k32.h"
#include "lut10_d32_k32.h"

#include <iostream>
using namespace std;

#define n 1024
#define d 32
#define k 32
#define log2kp3 6

typedef unsigned __int128 uint128_t;

void mulhilo(ap_uint<33> x, ap_uint<33> y, ap_uint<32> *hi, ap_uint<32> *lo, ap_uint<2> *redundant){ // x width d+1, y width d+1, hi width d, lo width d,
    ap_uint<66> res = (ap_uint<66>) x * (ap_uint<66>) y; // width 2*d+2
    *lo = res;
    *hi = res >> d;
    *redundant = res >> 2*d;
}





//Algorithm  7 and 9 Final Redundant-Representation PolynomialMultiplication Algorithm with final Reduction
void big_mul(ap_uint<(33)> z[k+1], ap_uint<(33)> x[k+1], ap_uint<(33)> y[k+1]/*, ap_uint<16> LUT[19][131072][16]*/){

//#pragma HLS INTERFACE s_axilite port=return bundle=ISAN
//#pragma HLS INTERFACE s_axilite register port=z bundle=ISAN
//#pragma HLS INTERFACE s_axilite port=x bundle=ISAN
//#pragma HLS INTERFACE s_axilite port=y bundle=ISAN

#pragma HLS ARRAY_RESHAPE variable=x complete dim=1
#pragma HLS ARRAY_RESHAPE variable=y complete dim=1
#pragma HLS ARRAY_RESHAPE variable=z complete dim=1


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

#pragma HLS pipeline II=1
#pragma HLS LATENCY max=1 min=1

    ap_uint<64> D[2*k+3]; // width 2*d
#pragma HLS ARRAY_RESHAPE variable=D complete dim=1

    ap_uint<64> C[2*k+3]; // width d+log2kp3
#pragma HLS ARRAY_RESHAPE variable=C complete dim=1

     for(i=0; i<2*k+3; i++){
#pragma HLS UNROLL factor=67//2*k+3
    	D[i]=0;
    }

     for(i=0; i<2*k+3; i++){
#pragma HLS UNROLL factor=67//2*k+3
    	C[i]=0;
    }


    for(i=0; i<k+1; i++){
#pragma HLS UNROLL factor=33//k+1
        for(j=0; j<k+1; j++){
#pragma HLS UNROLL factor=33//k+1

            int ipj = i + j;
            ap_uint<32> lo[(k+1)*(k+1)], hi[(k+1)*(k+1)];
            ap_uint<2> redundant[(k+1)*(k+1)];
            mulhilo(x[i], y[j], &hi[i*(k+1)+j], &lo[i*(k+1)+j], &redundant[i*(k+1)+j]);
            D[ipj] = D[ipj] + lo[i*(k+1)+j];
            D[ipj+1] = D[ipj+1] + hi[i*(k+1)+j];
            D[ipj+2] = D[ipj+2] + redundant[i*(k+1)+j];
        }
    }

    C[2*k+2]=D[2*k+2];

    for(i=0; i<2*k+2; i++){
#pragma HLS UNROLL factor=66//2*k+2
    	C[i]=C[i]+(D[i]&(0xFFFFFFFF));//0xFFFF);
    	C[i+1]=C[i+1]+(D[i]>>32);//>>16);
    	//printf("z[%d]:%d  z[%d]:%d\n",i,(unsigned )z[i],i+1,(unsigned )z[i+1]);
    }

     for(i=0; i<k; i++){
#pragma HLS UNROLL factor=32//k-1
    	D[i]=C[i];
    }

     for(i=k; i<2*k+3; i++){
#pragma HLS UNROLL factor=35//2*k+3
    	 for(j=0; j<k; j++){
#pragma HLS UNROLL factor=32//k
	   D[j]=D[j]+LUT21[i-k][j][(ap_uint<2>)(C[i]&0x3)];
	   D[j]=D[j]+LUT22[i-k][j][(ap_uint<2>)((C[i]>>2)&0x3)];
	   D[j]=D[j]+LUT23[i-k][j][(ap_uint<2>)((C[i]>>4)&0x3)];
	   D[j]=D[j]+LUT24[i-k][j][(ap_uint<2>)((C[i]>>6)&0x3)];
	   D[j]=D[j]+LUT25[i-k][j][(ap_uint<2>)((C[i]>>8)&0x3)];
	   D[j]=D[j]+LUT26[i-k][j][(ap_uint<2>)((C[i]>>10)&0x3)];
	   D[j]=D[j]+LUT27[i-k][j][(ap_uint<2>)((C[i]>>12)&0x3)];
	   D[j]=D[j]+LUT28[i-k][j][(ap_uint<2>)((C[i]>>14)&0x3)];
	   D[j]=D[j]+LUT29[i-k][j][(ap_uint<2>)((C[i]>>16)&0x3)];
	   D[j]=D[j]+LUT2A[i-k][j][(ap_uint<2>)((C[i]>>18)&0x3)];
	   D[j]=D[j]+LUT2B[i-k][j][(ap_uint<2>)((C[i]>>20)&0x3)];
	   D[j]=D[j]+LUT2C[i-k][j][(ap_uint<2>)((C[i]>>22)&0x3)];
	   D[j]=D[j]+LUT2D[i-k][j][(ap_uint<2>)((C[i]>>24)&0x3)];
	   D[j]=D[j]+LUT2E[i-k][j][(ap_uint<2>)((C[i]>>26)&0x3)];
	   D[j]=D[j]+LUT2F[i-k][j][(ap_uint<2>)((C[i]>>28)&0x3)];
	   D[j]=D[j]+LUT210[i-k][j][(ap_uint<2>)((C[i]>>30)&0x3)];
	   D[j]=D[j]+LUT10[i-k][j][(ap_uint<1>)((C[i]>>32)&0x1)];
		}
    }

     for(i=0; i<k; i++){
#pragma HLS UNROLL factor=32//k
    	z[i]=z[i]+(D[i]&(0xFFFFFFFF));
    	z[i+1]=z[i+1]+(D[i]>>32);
    }

}

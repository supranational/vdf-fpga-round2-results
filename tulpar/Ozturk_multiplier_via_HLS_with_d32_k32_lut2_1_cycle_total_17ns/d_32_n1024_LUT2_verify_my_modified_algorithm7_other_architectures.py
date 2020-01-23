

Debug=1
LUT_GENERATE_2_DIM=0
LUT_GENERATE_3_DIM=0

n=1024

d=32
k=int(n/d) # good to have powers of 2

Modulus=124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331

# # 256
#Modulus=74456466465445464645444444444444444466666666666666546464654646464646456451115


# 32
#Modulus=2554456153

# # 16
# Modulus=54651


# # 64
# Modulus=15544565465145464153


def mulhilo (x, y):
    res = x * y;
    lo = res & ((2**d) -1);
    hi = (res >> d) & ((2**d) -1);
    redundant = res >> (2*d);
    # print 'x',x
    # print 'y',y
    # print 'hi',hi
    # print 'lo',lo
    # print 'redundat',redundant

    return (redundant, hi, lo)



LUT21 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT22 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT23 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT24 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT25 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT26 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT27 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT28 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT29 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2A = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2B = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2C = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2D = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2E = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT2F = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT210 = [[[0 for kk in range(k)] for jj in range(2**(2))] for ii in range(k+3)]
LUT10 = [[[0 for kk in range(k)] for jj in range(2**(1))] for ii in range(k+3)]


# Algorithm 8  starts here 
#print 'my_LUT',LUT
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**(2)):
        T = ((j)*(2**((k*d)+d*i)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT21[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            # print 'k*t', k*t
            # print 'shift',T>>(k*t)
            # print 'mask:',((2**k) - 1)            
            #print  'i',i,'j',j,'t',t,'LUT',((T>>(k*t)) & ((2**d) - 1))
            #print LUT
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+2)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT22[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+4)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT23[i][j][t]=((T>>(d*t)) & ((2**d) - 1))


for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+6)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT24[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+8)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT25[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+10)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT26[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+12)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT27[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+14)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT28[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+16)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT29[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+18)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2A[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+20)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2B[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+22)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2C[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+24)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2D[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+26)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2E[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+28)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT2F[i][j][t]=((T>>(d*t)) & ((2**d) - 1))

for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**2):
        T = ((j)*(2**((k*d)+d*i+30)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT210[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
  
for i in range(0,k+3):
    #for j in range(0,d+1):
    for j in range(0,2**1):
        T = ((j)*(2**((k*d)+d*i+32)))%Modulus
        ##print hex(T)
        for t in range(0,k):
            LUT10[i][j][t]=((T>>(d*t)) & ((2**d) - 1))
            
            
            
def big_mul(z,x,y):
    
    D=[0]*(2*k+3);
    D2=[0]*(2*k+3);
    C=[0]*(2*k+3);
    lo=[0]*((k+1)*(k+1));            
    hi=[0]*((k+1)*(k+1));

    for i in range(0,2*k+3):
    	D[i]=0;   

    for i in range(0,2*k+3):
    	C[i]=0;
        
    for i in range(0,k+1):
        for j in range(0,k+1):

            ipj = i + j;
            redundant=[0]*((k+1)*(k+1))
            (redm, him, lom) = mulhilo(x[i], y[j]);
            #print 'x[',i,']:',hex(x[i]),'y[',j,']:',hex(y[j]),'redm:',hex(redm), 'him',hex(him),'lom',hex(lom)
            redundant[i*(k+1)+j] = redm;
            hi[i*(k+1)+j]=him;
            lo[i*(k+1)+j]=lom;    
            D[ipj] = D[ipj] + lo[i*(k+1)+j];
            D[ipj+1] = D[ipj+1] + hi[i*(k+1)+j];
            D[ipj+2] = D[ipj+2] + redundant[i*(k+1)+j];
            #print D[ipj].bit_length()
            #print D[ipj+1].bit_length()
            #print D[ipj+2].bit_length()
            
    ##print 'hi',hi
    ##print 'lo',lo

    #print 'res',res
    for i in range(0,2*k+3):
        C[i]=0;


    C[2*k+2]=D[2*k+2];

    for i in range(0,2*k+2):
    	C[i]=C[i]+(D[i]&(2**(d) -1));
    	C[i+1]=C[i+1]+(D[i]>>(d));
        #print (C[i].bit_length())
        
    # Algorithm 7 ends here.

    
    # Algorithm 9 starts here
    for i in range(0,k):
    	D2[i]=C[i];

    for i in range(k,2*k+3):
    	 for j in range(0,k):
             D2[j]=D2[j]+LUT21[i-k][(C[i])&0x3][j];
             D2[j]=D2[j]+LUT22[i-k][((C[i]>>2)&0x3)][j];
             D2[j]=D2[j]+LUT23[i-k][((C[i]>>4)&0x3)][j];
             D2[j]=D2[j]+LUT24[i-k][((C[i]>>6)&0x3)][j];
             D2[j]=D2[j]+LUT25[i-k][((C[i]>>8)&0x3)][j];
             D2[j]=D2[j]+LUT26[i-k][((C[i]>>10)&0x3)][j];
             D2[j]=D2[j]+LUT27[i-k][((C[i]>>12)&0x3)][j];
             D2[j]=D2[j]+LUT28[i-k][((C[i]>>14)&0x3)][j];
             D2[j]=D2[j]+LUT29[i-k][((C[i]>>16)&0x3)][j];
             D2[j]=D2[j]+LUT2A[i-k][((C[i]>>18)&0x3)][j];
             D2[j]=D2[j]+LUT2B[i-k][((C[i]>>20)&0x3)][j];
             D2[j]=D2[j]+LUT2C[i-k][((C[i]>>22)&0x3)][j];
             D2[j]=D2[j]+LUT2D[i-k][((C[i]>>24)&0x3)][j];
             D2[j]=D2[j]+LUT2E[i-k][((C[i]>>26)&0x3)][j];
             D2[j]=D2[j]+LUT2F[i-k][((C[i]>>28)&0x3)][j];
             D2[j]=D2[j]+LUT210[i-k][((C[i]>>30)&0x3)][j];
             D2[j]=D2[j]+LUT10[i-k][((C[i]>>32)&0x1)][j];
   
         
    		     
    # Algorithm 9 starts here.
    for i in range(0,k):
        z[i]=0;
    

    for i in range(0,k):
        z[i]=z[i]+(D2[i]&(2**(d) -1));
        z[i+1]=z[i+1]+(D2[i]>>(d));
        if Debug==1:
            if((D2[i]>>(d)) > 0):
                print ('Exceeded:', D2[i]>>(d))
        



def inttopolly(A):
    polly=[0]*(k+1);
    for i in range (0,k+1):	
        polly[i]=(A>>i*(d)) & ((2**(d))-1)

    return polly    

def pollytoint(pollyin):
    A=0
    for i in range (0,k+1):	
        A+=pollyin[i]<<(i*(d))

    return A   
        
x=[0]*(k+1);
y=[0]*(k+1);
z=[0]*(k+1);

# # 1024
# xin=0x1580000014f000001460000013d000001340000012b00000122000001190000011000000107000000fe000000f5000000ec000000e3000000da000000d1000000c8000000bf000000b6000000ad000000a40000009b000000920000008900000080000000770000006e000000650000005c000000530000004a00000041;
# yin=0x1580000014f000001460000013d000001340000012b00000122000001190000011000000107000000fe000000f5000000ec000000e3000000da000000d1000000c8000000bf000000b6000000ad000000a40000009b000000920000008900000080000000770000006e000000650000005c000000530000004a00000041;

# # 256
# xin=34456466465445464645444444444444444466666666666666546464654646464646456451115
# yin=34456466465445464645444444444444444466666666666666546464654646464646456451115

# # 64
# xin=9556466465445464613
# yin=9556466465445464613

# # 32
# xin=255445613
# yin=255445613

# # 16
# xin=15613
# yin=15613

# 1024
xin=0x15805465465465413211321231321131321213212eded3121313231131131231313213212313123131321324654562341646512312312132123453456321321132465456464654544321321e321e321e321e23e123e132e1e13e123e1e321e321ee31e31e321e213e23121321f231f1231f231f321f231f23132f1ededf32f32;
yin=0x15805465465465413211321231321131321213212eded3121313231131131231313213212313123131321324654562341646512312312132123453456321321132465456464654544321321e321e321e321e23e123e132e1e13e123e1e321e321ee31e31e321e213e23121321f231f1231f231f321f231f23132f1ededf32f32;

#xin=2**512
#yin=2**512

x=inttopolly(xin);
y=inttopolly(yin);


if (Debug==1):
    print ('x:', x)
    print ('y:', x)
            
big_mul(z,x,y);


zout=pollytoint(z);


if (Debug==1):
    print ('correct result:', hex((xin*yin)%Modulus))

    print ('big_mul   zout:', hex(zout))

    for i in range(0,k+1):
        print ('z[',i,']:', hex(z[i]))
        print ('bitlength of z[',i,']:',z[i].bit_length())

    print ('length of xin', xin.bit_length())
    print ('length of yin', yin.bit_length())
    print ('length of Mod', Modulus.bit_length())
    if ((xin*yin)%Modulus == zout%Modulus):
        print ('CORRECT!!!!!!!!!!!!!!!!!!!!!')
    else:
        print ('ERROR')

if LUT_GENERATE_3_DIM ==1:    
    # LUT Generation
    for i in range(0,1):
        print ('#include "ap_int.h"')
        print (''            )
        print ('ap_uint<32> LUT10[',(k+3), '][', k,'][',2**(1),'] = {')
        for i in range(0,k+3):
            print ('{ ')
            for t in range(0,k):
                print ('{ ', end = '')            
                for j in range(0,2**(1)):
                    if(j==(2**(1))-1):
                        # last k value without comma           
                        print (hex(LUT10[i][j][t]) , end = '')
                    else:    
                        print (hex(LUT10[i][j][t]), ', ', end = '')               

            
                if (t==k-1):
                    print('}')
                else:    
                    print ('},')
            if (i==k+3-1):
                print('}')
            else:    
                print ('},')  
            
        print ('};', end = '')



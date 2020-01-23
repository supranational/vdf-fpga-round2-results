def gen_retuction_lut(file_name, p, num_low, num_high, num_final, step):
    f = open(file_name, 'w')
    #pb = (2**1024-p) * (2**(16*(58+1)))
    pb = (2 ** 1024 - p)
    pbh = (2**1024-p)* (2**(16*(1)))
    #temp_pb = pb % p
    data = """
/*******************************************************************************
  Copyright 2019 xjtu

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
    """
    data = data + '\n\n\n'
    data = data + """module xpb_lut_low
(
    input logic [16:0] flag[%(num_flag)d],
    output logic [1023:0] xpb[%(num_xpb)d]
);
        
        
""" % {'num_flag': num_low, 'num_xpb': num_low * 3}
    for j in range(num_low):
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][5:0])\n'% { 'j': j}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j*3, 'k':((pb * (2**(j*step))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][11:6])\n'% { 'j': j}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 1, 'k':((pb * (2**(j*step + 6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][16:12])\n'% { 'j': j}
        for i in range(2**5):
            data = data + '            5\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 2, 'k':((pb * (2**(j*step + 6+6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
    data = data + '\n\nendmodule'

    data = data + '\n\n\n\n'

    data = data + """module xpb_lut_high
(
    input logic [16:0] flag[%(num_flag)d],
    output logic [1023:0] xpb[%(num_xpb)d]
);
        
        
""" % {'num_flag': num_high, 'num_xpb': num_high * 3}
    for j in range(num_high):
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][5:0])\n'% { 'j': j}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j*3, 'k':((pbh * (2**(j*step))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][11:6])\n'% { 'j': j}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 1, 'k':((pbh * (2**(j*step + 6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d][16:12])\n'% { 'j': j}
        for i in range(2**5):
            data = data + '            5\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 2, 'k':((pbh * (2**(j*step + 6+6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
    data = data + '\n\nendmodule'

    data = data + '\n\n\n\n'


    data = data + """module xpb_lut_final
(
    input logic [16:0] flag,
    output logic [1023:0] xpb[%(num_xpb)d]
);
        
        
""" % {'num_xpb': num_final * 3}
    for j in range(num_final):
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[5:0])\n'
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j*3, 'k':((pb * (2**(j*step))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[11:6])\n'
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 1, 'k':((pb * (2**(j*step + 6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[16:12])\n'
        for i in range(2**5):
            data = data + '            5\'d%(i)d: xpb[%(j)d] = 1024\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 2, 'k':((pb * (2**(j*step + 6+6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
    data = data + '\n\nendmodule'

    data = data + '\n\n\n\n'
    
    f.write(data)
        

    f.close()

if __name__ == "__main__":
    file_name = "./xpb_lut.sv"
    p = 124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331
    num_low = 3
    num_high = 66
    num_final = 1
    step = 16

    gen_retuction_lut(file_name, p, num_low, num_high, num_final, step)
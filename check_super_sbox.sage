import os
import itertools as its
os.system("sage -preparse super_sbox_info.sage")
os.system("mv super_sbox_info.sage.py super_sbox_info.py")
from super_sbox_info  import super_sbox_dict

class SuperSbox:

    def hex_to_vec(self, hex_val, reverse = False):
        vec = []
        thex_val = int(hex_val)
        for i in range(self.sboxbsz):
            if((thex_val % 2) != 0):
                vec.append(1)
            else:
                vec.append(0)
            thex_val = thex_val//2
        
        if reverse == True:
            vec.reverse()
        return vec
    
    def vec_to_hex(self, vec, reverse = False):
        if reverse == True:
            t_vec = list(reversed(vec))
        else:
            t_vec = list(vec)
        
        out_val = 0
        for idx in range(self.sboxbsz):
            if t_vec[idx] == 1:
                out_val += (2**idx)
        return int(out_val)

    def hex_to_field_ele(self, hex_val):
        return self.field(self.hex_to_vec(hex_val))

    def field_ele_to_hex(self, field_ele):
        return field_ele._int_repr()
    
    def analysis_plateau_char(self, set_load = False, load_vec = []):
        self.ana_rst_tab = dict()
        
        self.is_active      = [False] * 8
        self.has_uni4       = [False] * 8
        self.val_uni4       = [None]  * 8
        self.has_uni2       = [False] * 8
        self.val_uni2       = [None]  * 8
        self.base_vec       = [None]  * 8

        self.b      = [None] * 4
        self.c      = [0] * 4

        self.B      = [None] * 4

        if set_load == False:
            self.B[0] = list(range(self.sboxsize))
            self.B[1] = list(range(self.sboxsize))
            self.B[2] = list(range(self.sboxsize))
            self.B[3] = list(range(self.sboxsize))
        else:
            self.B[0] = list(load_vec[0])
            self.B[1] = list(load_vec[1])
            self.B[2] = list(load_vec[2])
            self.B[3] = list(load_vec[3])

        self.analysis_plateau_char_core(s_idx = 0)

        return self.ana_rst_tab

    def analysis_plateau_char_core(self, s_idx):
        # a : Uab
        #  □ □ □ □ 
        # b : Vab
        # ┌--------┐
        # │  mat   │
        # │        │
        # └--------┘
        # b': MVab
        # c : Ucd
        #  □ □ □ □
        # d : Vcd

        # determine b
        for b0 in self.B[0]:
            self.b[0] = b0
            self.is_active[0] = (b0 != 0)
            self.has_uni4[0]  = self.has_uniform4_fix_ou[b0]
            self.val_uni4[0]  = self.in_set_uniform4_fix_ou[b0]
            self.has_uni2[0]  = self.has_uniform2_fix_ou[b0]
            self.val_uni2[0]  = self.in_set_uniform2_fix_ou[b0]
            self.base_vec[0]  = self.Mb_base_vector[0][b0]
            Mb0 = self.MatMul[0][b0]
            self.c[0] = self.c[0] ^^ Mb0[0]
            self.c[1] = self.c[1] ^^ Mb0[1]
            self.c[2] = self.c[2] ^^ Mb0[2]
            self.c[3] = self.c[3] ^^ Mb0[3]
            for b1 in self.B[1]:
                self.b[1] = b1
                self.is_active[1] = (b1 != 0)
                self.has_uni4[1]  = self.has_uniform4_fix_ou[b1]
                self.val_uni4[1]  = self.in_set_uniform4_fix_ou[b1]
                self.has_uni2[1]  = self.has_uniform2_fix_ou[b1]
                self.val_uni2[1]  = self.in_set_uniform2_fix_ou[b1]
                self.base_vec[1]  = self.Mb_base_vector[1][b1]
                Mb1 = self.MatMul[1][b1]
                self.c[0] = self.c[0] ^^ Mb1[0]
                self.c[1] = self.c[1] ^^ Mb1[1]
                self.c[2] = self.c[2] ^^ Mb1[2]
                self.c[3] = self.c[3] ^^ Mb1[3]
                for b2 in self.B[2]:
                    self.b[2] = b2
                    self.is_active[2] = (b2 != 0)
                    self.has_uni4[2]  = self.has_uniform4_fix_ou[b2]
                    self.val_uni4[2]  = self.in_set_uniform4_fix_ou[b2]
                    self.has_uni2[2]  = self.has_uniform2_fix_ou[b2]
                    self.val_uni2[2]  = self.in_set_uniform2_fix_ou[b2]
                    self.base_vec[2]  = self.Mb_base_vector[2][b2]
                    Mb2 = self.MatMul[2][b2]
                    self.c[0] = self.c[0] ^^ Mb2[0]
                    self.c[1] = self.c[1] ^^ Mb2[1]
                    self.c[2] = self.c[2] ^^ Mb2[2]
                    self.c[3] = self.c[3] ^^ Mb2[3]
                    for b3 in self.B[3]:
                        self.b[3] = b3
                        if tuple(self.b) == (0, 0, 0, 0):
                            continue
                        self.is_active[3] = (b3 != 0)
                        self.has_uni4[3]  = self.has_uniform4_fix_ou[b3]
                        self.val_uni4[3]  = self.in_set_uniform4_fix_ou[b3]
                        self.has_uni2[3]  = self.has_uniform2_fix_ou[b3]
                        self.val_uni2[3]  = self.in_set_uniform2_fix_ou[b3]
                        self.base_vec[3]  = self.Mb_base_vector[3][b3]
                        Mb3 = self.MatMul[3][b3]
                        self.c[0] = self.c[0] ^^ Mb3[0]
                        self.c[1] = self.c[1] ^^ Mb3[1]
                        self.c[2] = self.c[2] ^^ Mb3[2]
                        self.c[3] = self.c[3] ^^ Mb3[3]

                        self.analysis_plateau_char_fin()

                        self.c[0] = self.c[0] ^^ Mb3[0]
                        self.c[1] = self.c[1] ^^ Mb3[1]
                        self.c[2] = self.c[2] ^^ Mb3[2]
                        self.c[3] = self.c[3] ^^ Mb3[3]
                    self.c[0] = self.c[0] ^^ Mb2[0]
                    self.c[1] = self.c[1] ^^ Mb2[1]
                    self.c[2] = self.c[2] ^^ Mb2[2]
                    self.c[3] = self.c[3] ^^ Mb2[3]
                self.c[0] = self.c[0] ^^ Mb1[0]
                self.c[1] = self.c[1] ^^ Mb1[1]
                self.c[2] = self.c[2] ^^ Mb1[2]
                self.c[3] = self.c[3] ^^ Mb1[3]
            self.c[0] = self.c[0] ^^ Mb0[0]
            self.c[1] = self.c[1] ^^ Mb0[1]
            self.c[2] = self.c[2] ^^ Mb0[2]
            self.c[3] = self.c[3] ^^ Mb0[3]

    def analysis_plateau_char_fin(self):
        
        for sidx in range(4, 8):
            ci = self.c[sidx - 4]
            self.is_active[sidx] = (ci != 0)
            self.has_uni4[sidx]  = self.has_uniform4_fix_in[ci]
            self.val_uni4[sidx]  = self.ou_set_uniform4_fix_in[ci]
            self.has_uni2[sidx]  = self.has_uniform2_fix_in[ci]
            self.val_uni2[sidx]  = self.ou_set_uniform2_fix_in[ci]
            self.base_vec[sidx]  = self.c_base_vector[sidx - 4][ci]
        
        
        self.num_act   = self.is_active.count(True)

        #Cases for S-boxes to have uni4
        self.chan_uni4_idx = []
        self.must_uni4_idx = []
        
        for s_idx in range(8):
            if self.is_active[s_idx] == True:
                if self.has_uni4[s_idx] == True:
                    if self.has_uni2[s_idx] == True:
                        self.chan_uni4_idx.append(s_idx)
                    else:
                        self.must_uni4_idx.append(s_idx)        

        for num_chan_uni4 in range(len(self.chan_uni4_idx) + 1):
            c = its.combinations(self.chan_uni4_idx, num_chan_uni4)
            self.num_uni4 = len(self.must_uni4_idx) + num_chan_uni4
            self.num_uni2 = self.num_act - self.num_uni4
            self.weight   = (self.sboxbsz - 2)*self.num_uni4 + (self.sboxbsz - 1)*self.num_uni2
            self.auxi_vec = [None] * 8

            for chan_uni4_idx_list in c:
                self.analysis_plateau_char_fin_core(s_idx = 0, change_uni4_idx_list = set(list(chan_uni4_idx_list) + self.must_uni4_idx), howmany = 1)


    def analysis_plateau_char_fin_core(self, s_idx, change_uni4_idx_list, howmany):

        if s_idx < 4:
            b_idx = s_idx
            if s_idx in change_uni4_idx_list:
                bi = self.b[b_idx]
                for ai in self.in_set_uniform4_fix_ou[bi]:
                    self.auxi_vec[s_idx] = self.Mb_auxi_vector[b_idx][(ai, bi)]
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany)
            else:
                self.auxi_vec[s_idx] = []
                if self.is_active[s_idx]:
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany*len(self.val_uni2[s_idx]))
                else:
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany)
        elif s_idx < 8:
            c_idx = s_idx - 4
            if s_idx in change_uni4_idx_list:
                ci = self.c[c_idx]
                for di in self.ou_set_uniform4_fix_in[ci]:
                    self.auxi_vec[s_idx] = self.c_auxi_vector[c_idx][(ci, di)]
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany)
            else:
                self.auxi_vec[s_idx] = []
                if self.is_active[s_idx]:
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany*len(self.val_uni2[s_idx]))
                else:
                    self.analysis_plateau_char_fin_core(s_idx + 1, change_uni4_idx_list, howmany)
        else:
            #method 1
            '''
            MVab = self.V.subspace(
                self.base_vec[0] + self.base_vec[1] + self.base_vec[2] + self.base_vec[3] + 
                self.auxi_vec[0] + self.auxi_vec[1] + self.auxi_vec[2] + self.auxi_vec[3]
            )
            Ucd  = self.V.subspace(
                self.base_vec[4] + self.base_vec[5] + self.base_vec[6] + self.base_vec[7] + 
                self.auxi_vec[4] + self.auxi_vec[5] + self.auxi_vec[6] + self.auxi_vec[7]
            )
            height = MVab.intersection(Ucd).dimension()
            '''

            #method2 -> this is about 2 times faster than the above method
            #dim(MVab \intersection Ucd) = dim(MVab) + dim(Ucd) - dim(MVab + Ucd)
            #Note that the vectors in MVab(or Ucd) are "all" basis vectors
            MVab = self.base_vec[0] + self.base_vec[1] + self.base_vec[2] + self.base_vec[3] + self.auxi_vec[0] + self.auxi_vec[1] + self.auxi_vec[2] + self.auxi_vec[3]
            Ucd  = self.base_vec[4] + self.base_vec[5] + self.base_vec[6] + self.base_vec[7] + self.auxi_vec[4] + self.auxi_vec[5] + self.auxi_vec[6] + self.auxi_vec[7]
            height = len(MVab) + len(Ucd) - self.V.subspace(set(MVab + Ucd)).dimension()

            IDX = (self.num_act, self.weight, height)
            if IDX not in self.ana_rst_tab.keys():
                self.ana_rst_tab[IDX]  = howmany
            else:
                self.ana_rst_tab[IDX] += howmany


    def prep(self):
        self.ddt             = [([0]*self.sboxsize) for i in range(self.sboxsize)]
        self.extended_ddt_in = [([None]*self.sboxsize) for i in range(self.sboxsize)]
        self.extended_ddt_ou = [([None]*self.sboxsize) for i in range(self.sboxsize)]

        self.ou_set_uniform4_fix_in = [None] * self.sboxsize
        self.has_uniform4_fix_in    = [False] * self.sboxsize
        self.ou_set_uniform2_fix_in = [None] * self.sboxsize
        self.has_uniform2_fix_in    = [False] * self.sboxsize
        self.in_set_uniform4_fix_ou = [None] * self.sboxsize
        self.has_uniform4_fix_ou    = [False] * self.sboxsize
        self.in_set_uniform2_fix_ou = [None] * self.sboxsize
        self.has_uniform2_fix_ou    = [False] * self.sboxsize

        for in_dif in range(self.sboxsize):
            for ou_dif in range(self.sboxsize):
                self.extended_ddt_in[in_dif][ou_dif] = []
                self.extended_ddt_ou[in_dif][ou_dif] = []

        for in_val1 in range(self.sboxsize):
            for in_dif in range(self.sboxsize):
                in_val2 = in_val1 ^^ in_dif
                ou_val1 = self.sbox[in_val1]
                ou_val2 = self.sbox[in_val2]
                ou_dif  = ou_val1 ^^ ou_val2
                self.ddt[in_dif][ou_dif] += 1
                self.extended_ddt_in[in_dif][ou_dif] += [in_val1, in_val2]
                self.extended_ddt_ou[in_dif][ou_dif] += [ou_val1, ou_val2]


        for in_dif in range(self.sboxsize):
            for ou_dif in range(self.sboxsize):
                if ((in_dif, ou_dif) != (0, 0))  and (self.ddt[in_dif][ou_dif] not in [0, 2, 4]):
                    raise ValueError("The DDT of S-box must have the differential uniformity of 4, got %d"%(self.ddt[in_dif][ou_dif]))

        for dif1 in range(self.sboxsize):
            self.ou_set_uniform4_fix_in[dif1] = []
            self.ou_set_uniform2_fix_in[dif1] = []
            self.in_set_uniform4_fix_ou[dif1] = []
            self.in_set_uniform2_fix_ou[dif1] = []
            for dif2 in range(self.sboxsize):
                if self.ddt[dif1][dif2] == 4:
                    self.ou_set_uniform4_fix_in[dif1].append(dif2)
                elif self.ddt[dif1][dif2] == 2:
                    self.ou_set_uniform2_fix_in[dif1].append(dif2)

                if self.ddt[dif2][dif1] == 4:
                    self.in_set_uniform4_fix_ou[dif1].append(dif2)
                elif self.ddt[dif2][dif1] == 2:
                    self.in_set_uniform2_fix_ou[dif1].append(dif2)            
            
            if(self.ou_set_uniform4_fix_in[dif1] != []):
                self.has_uniform4_fix_in[dif1] = True
            else:
                self.has_uniform4_fix_in[dif1] = False

            if(self.ou_set_uniform2_fix_in[dif1] != []):
                self.has_uniform2_fix_in[dif1] = True
            else:
                self.has_uniform2_fix_in[dif1] = False

            if(self.in_set_uniform4_fix_ou[dif1] != []):
                self.has_uniform4_fix_ou[dif1] = True
            else:
                self.has_uniform4_fix_ou[dif1] = False

            if(self.in_set_uniform2_fix_ou[dif1] != []):
                self.has_uniform2_fix_ou[dif1] = True
            else:
                self.has_uniform2_fix_ou[dif1] = False     
        
        
        #normalizing
        self.extended_ddt_in_base = dict()
        self.extended_ddt_in_auxi = dict()
        self.extended_ddt_ou_base = dict()
        self.extended_ddt_ou_auxi = dict()
        
        for in_dif in range(self.sboxsize):
            if in_dif == 0:
                self.extended_ddt_in_base[in_dif] = [2**i for i in range(self.sboxbsz)]
            else:
                self.extended_ddt_in_base[in_dif] = [in_dif]
    
        for ou_dif in range(self.sboxsize):
            if ou_dif == 0:
                self.extended_ddt_ou_base[ou_dif] = [2**i for i in range(self.sboxbsz)]
            else:
                self.extended_ddt_ou_base[ou_dif] = [ou_dif]


        for in_dif in range(self.sboxsize):
            for ou_dif in range(self.sboxsize):
                if (in_dif, ou_dif) == (0, 0):
                    self.extended_ddt_in_auxi[(in_dif, ou_dif)] = []
                    self.extended_ddt_ou_auxi[(in_dif, ou_dif)] = []
                else:
                    if(self.ddt[in_dif][ou_dif] == 0):
                        self.extended_ddt_in_auxi[(in_dif, ou_dif)] = []
                        self.extended_ddt_ou_auxi[(in_dif, ou_dif)] = []
                    elif(self.ddt[in_dif][ou_dif] == 2):
                        self.extended_ddt_in_auxi[(in_dif, ou_dif)] = []
                        self.extended_ddt_ou_auxi[(in_dif, ou_dif)] = []
                    elif(self.ddt[in_dif][ou_dif] == 4):
                        in_affine = list(set(self.extended_ddt_in[in_dif][ou_dif]))
                        ou_affine = list(set(self.extended_ddt_ou[in_dif][ou_dif]))
                        
                        in_vec = []
                        for ele in in_affine:
                            in_vec.append(ele ^^ in_affine[0])
                        in_vec.remove(0)
                        in_vec.remove(in_dif)
                        assert(len(in_vec) == 2)
                        self.extended_ddt_in_auxi[(in_dif, ou_dif)] = [in_vec[0]]

                        ou_vec = []
                        for ele in ou_affine:
                            ou_vec.append(ele ^^ ou_affine[0])
                        ou_vec.remove(0)
                        ou_vec.remove(ou_dif)
                        assert(len(ou_vec) == 2)
                        self.extended_ddt_ou_auxi[(in_dif, ou_dif)] = [ou_vec[0]]

        self.MatMul = [None]*4
        for idx in range(4):
            self.MatMul[idx] = dict()
            for b_val in range(self.sboxsize):
                if self.is_matrix_permutation == False:
                    arith_vec = [self.field_zero, self.field_zero, self.field_zero, self.field_zero]
                    arith_vec[idx] = self.hex_to_field_ele(b_val)
                    arith_vec = self.mat * vector(self.field, arith_vec)
                    Mb_vec = []
                    for ele in arith_vec:
                        Mb_vec.append(int(ele._int_repr()))
                else:
                    arith_vec = [0] * self.statebsz
                    arith_vec[idx * self.sboxbsz : (idx + 1) * self.sboxbsz] = self.hex_to_vec(int(b_val), reverse=True)
                    arith_vec = self.mat * vector(GF(2), arith_vec)
                    Mb_vec = [
                        self.vec_to_hex(arith_vec[0:self.sboxbsz], reverse=True),
                        self.vec_to_hex(arith_vec[self.sboxbsz:2*self.sboxbsz], reverse=True),
                        self.vec_to_hex(arith_vec[2*self.sboxbsz:3*self.sboxbsz], reverse=True),
                        self.vec_to_hex(arith_vec[3*self.sboxbsz:4*self.sboxbsz], reverse=True)
                    ]
                self.MatMul[idx][b_val] = tuple(Mb_vec)


        self.Mb_base_vector = [None]*4
        self.c_base_vector  = [None]*4

        self.Mb_auxi_vector = [None]*4
        self.c_auxi_vector = [None]*4

        for idx in range(4):
            self.Mb_base_vector[idx] = dict()
            for b_val in sorted(list(self.extended_ddt_ou_base.keys())):
                self.Mb_base_vector[idx][b_val] = []
                for base_vec in self.extended_ddt_ou_base[b_val]:
                    if self.is_matrix_permutation == False:
                        arith_vec = [self.field_zero, self.field_zero, self.field_zero, self.field_zero]
                        arith_vec[idx] = self.hex_to_field_ele(base_vec)
                        arith_vec = self.mat * vector(self.field, arith_vec)
                        vec = []
                        for f_ele in arith_vec:
                            vec += self.hex_to_vec(int(f_ele._int_repr()), reverse = True)
                    else:
                        arith_vec = [0] * self.statebsz
                        arith_vec[idx * self.sboxbsz : (idx + 1) * self.sboxbsz] = self.hex_to_vec(int(base_vec), reverse=True)
                        arith_vec = self.mat * vector(GF(2), arith_vec)
                        vec = []
                        for f_ele in arith_vec:
                            vec += [int(f_ele)]
                    
                    self.Mb_base_vector[idx][b_val].append(tuple(vec))

            self.c_base_vector[idx] = dict()
            for c_val in sorted(list(self.extended_ddt_in_base.keys())):
                self.c_base_vector[idx][c_val] = []
                for base_vec in self.extended_ddt_in_base[c_val]:
                    vec        = [0]*self.statebsz
                    c_val_vec  = list(self.hex_to_vec(base_vec, reverse=True))
                    vec[idx*self.sboxbsz : (idx + 1)*self.sboxbsz] = c_val_vec
                    self.c_base_vector[idx][c_val].append(tuple(vec))

            self.Mb_auxi_vector[idx] = dict()
            for in_dif in range(self.sboxsize):
                for ou_dif in range(self.sboxsize):                    
                    self.Mb_auxi_vector[idx][(in_dif, ou_dif)] = []
                    if self.extended_ddt_ou_auxi[(in_dif, ou_dif)] == []:
                        self.Mb_auxi_vector[idx][(in_dif, ou_dif)].append(tuple([0]*self.statebsz))
                    else:
                        for ou_val in self.extended_ddt_ou_auxi[(in_dif, ou_dif)]:
                            if self.is_matrix_permutation == False:
                                arith_vec = [self.field_zero, self.field_zero, self.field_zero, self.field_zero]
                                arith_vec[idx] = self.hex_to_field_ele(ou_val)
                                arith_vec = self.mat * vector(self.field, arith_vec)
                                vec = []
                                for f_ele in arith_vec:
                                    vec += self.hex_to_vec(int(f_ele._int_repr()), reverse = True)
                            else:
                                arith_vec = [0] * self.statebsz
                                arith_vec[idx * self.sboxbsz : (idx + 1) * self.sboxbsz] = self.hex_to_vec(int(ou_val), reverse=True)
                                arith_vec = self.mat * vector(GF(2), arith_vec)
                                vec = []
                                for f_ele in arith_vec:
                                    vec += [int(f_ele)]
                            self.Mb_auxi_vector[idx][(in_dif, ou_dif)].append(tuple(vec))

            self.c_auxi_vector[idx] = dict()
            for in_dif in range(self.sboxsize):
                for ou_dif in range(self.sboxsize):
                    self.c_auxi_vector[idx][(in_dif, ou_dif)] = []
                    if self.extended_ddt_in_auxi[(in_dif, ou_dif)] == []:
                        self.c_auxi_vector[idx][(in_dif, ou_dif)].append(tuple([0]*self.statebsz))
                    else:
                        for in_val in self.extended_ddt_in_auxi[(in_dif, ou_dif)]:
                            vec        = [0]*self.statebsz
                            in_val_vec = list(self.hex_to_vec(in_val, reverse=True))
                            vec[idx*self.sboxbsz : (idx + 1)*self.sboxbsz] = in_val_vec
                            self.c_auxi_vector[idx][(in_dif, ou_dif)].append(tuple(vec))

    def get_num_valid_trails(self, set_load = False, load_vec = []):
        self.valid_trails_dict = dict()

        if set_load == False:
            if self.is_matrix_permutation == False:
                I0 = self.field_list
                I1 = self.field_list
                I2 = self.field_list
                I3 = self.field_list
            else:
                I0 = list(range(self.sboxsize))
                I1 = list(range(self.sboxsize))
                I2 = list(range(self.sboxsize))
                I3 = list(range(self.sboxsize))
        else:
            if self.is_matrix_permutation == False:
                I0 = [self.hex_to_field_ele(x) for x in load_vec[0]]
                I1 = [self.hex_to_field_ele(x) for x in load_vec[1]]
                I2 = [self.hex_to_field_ele(x) for x in load_vec[2]]
                I3 = [self.hex_to_field_ele(x) for x in load_vec[3]]
            else:
                I0 = [x for x in load_vec[0]]
                I1 = [x for x in load_vec[1]]
                I2 = [x for x in load_vec[2]]
                I3 = [x for x in load_vec[3]]

        for i0 in I0:
            for i1 in I1:
                for i2 in I2:
                    for i3 in I3:
                        if self.is_matrix_permutation == False:
                            in_vec = vector(self.field, [i0, i1, i2, i3])
                            ou_vec = self.mat * in_vec
                            num_act = 0
                            how_many = 1
                            for idx in range(4):
                                ii = int(in_vec[idx]._int_repr())
                                oi = int(ou_vec[idx]._int_repr())
                                if ii != 0:
                                    num_act+=1
                                    how_many *= (len(self.in_set_uniform4_fix_ou[ii]) + len(self.in_set_uniform2_fix_ou[ii]))
                                if oi != 0:
                                    num_act+=1
                                    how_many *= (len(self.ou_set_uniform4_fix_in[oi]) + len(self.ou_set_uniform2_fix_in[oi]))
                        else:
                            t_in_vec = vector(GF(2), self.hex_to_vec(i0, reverse=True) + self.hex_to_vec(i1, reverse=True) + self.hex_to_vec(i2, reverse=True) + self.hex_to_vec(i3, reverse=True))
                            t_ou_vec = self.mat * t_in_vec
                            in_vec   = [i0, i1, i2, i3]
                            ou_vec   = []
                            num_act = 0
                            how_many = 1
                            for idx in range(4):
                                ou_vec.append(self.vec_to_hex(t_ou_vec[idx * self.sboxbsz : (idx + 1) * self.sboxbsz], reverse=True))

                            for idx in range(4):
                                ii = in_vec[idx]
                                oi = ou_vec[idx]
                                if ii != 0:
                                    num_act+=1
                                    how_many *= (len(self.in_set_uniform4_fix_ou[ii]) + len(self.in_set_uniform2_fix_ou[ii]))
                                if oi != 0:
                                    num_act+=1
                                    how_many *= (len(self.ou_set_uniform4_fix_in[oi]) + len(self.ou_set_uniform2_fix_in[oi]))

                        if num_act not in self.valid_trails_dict.keys():
                            self.valid_trails_dict[num_act] = how_many
                        else:
                            self.valid_trails_dict[num_act] += how_many

        return self.valid_trails_dict

    def __init__(self, sbox, field, mat):
        self.sbox       = sbox
        self.sboxsize   = len(self.sbox)
        self.sboxbsz    = int(log(self.sboxsize, 2))
        self.statebsz   = self.sboxbsz * 4

        if field.cardinality() == 2:
            self.is_matrix_permutation = True
            if len(mat) != (int(log(self.sboxsize, 2))*4) or len(mat[0]) != (int(log(self.sboxsize, 2))*4):
                raise ValueError("Matrix Must be %d X %d"%((int(log(self.sboxsize, 2))*4), (int(log(self.sboxsize, 2))*4)))
            if len(sbox) != len(set(sbox)):
                raise ValueError("S-box Must be Invertible")
        else:
            self.is_matrix_permutation = False
            if len(sbox) != field.cardinality():
                raise ValueError("Field Size must be the same as the size of S-box.")
            if len(mat) != 4 or len(mat[0]) != 4:
                raise ValueError("Matrix Must be 4 X 4")
            if len(sbox) != len(set(sbox)):
                raise ValueError("S-box Must be Invertible")
        

        self.V          = VectorSpace(GF(2),self.statebsz)

        if self.is_matrix_permutation == False:
            self.field      = GF(field.cardinality(), name = 'a', repr = 'int', modulus = field.modulus())
            self.field_zero = self.field(0)
            self.field_list = list(self.field.list())
            self.field_star_list = list(self.field.list())
            self.field_star_list.remove(self.field_zero)

            self.field_list.sort(key=lambda x : int(x._int_repr()))
            self.field_star_list.sort(key=lambda x : int(x._int_repr()))

            self.mat        = [None]*4
            self.mat[0]     = list(mat[0])
            self.mat[1]     = list(mat[1])
            self.mat[2]     = list(mat[2])
            self.mat[3]     = list(mat[3])
            
            for r in range(4):
                for c in range(4):
                    self.mat[r][c] = self.hex_to_field_ele(int(self.mat[r][c]))
            self.mat = matrix(self.field, self.mat)
        else:
            self.mat        = [None]*self.statebsz
            for idx in range(self.statebsz):
                self.mat[idx] = list(mat[idx])
            self.mat = matrix(GF(2), self.mat)
        
        self.prep()

if __name__ == "__main__":
    import datetime

    for alg in sorted(list(super_sbox_dict.keys())):
        print(alg.upper())
    ALGNAME = str(input("algname > "))
    S = SuperSbox(super_sbox_dict[ALGNAME.upper()]["sbox"], super_sbox_dict[ALGNAME.upper()]["field"], super_sbox_dict[ALGNAME.upper()]["matrix"])
    
    ##Setting Workloads
    COMP_NUM = 4
    print('##Setting Workloads')
    load_vec = [None]*4
    for idx in range(COMP_NUM):
        load_vec[idx] = list(range(S.sboxsize))
        print(idx, load_vec[idx])
    for idx in range(COMP_NUM, 4):
        load_vec[idx] = [0]
        print(idx, load_vec[idx])

    ##Compute Valid Trails
    start = datetime.datetime.now()
    print('##Compute Valid Trails')
    S.get_num_valid_trails(set_load = True, load_vec = load_vec)    
    end = datetime.datetime.now()
    print(end - start)
    total_number_of_valid_trails = 0
    for k in sorted(list(S.valid_trails_dict.keys())):
        if k == 0:
            continue
        print("%2d : "%(k), S.valid_trails_dict[k])
        total_number_of_valid_trails+=S.valid_trails_dict[k]
    print("  --> %d"%(total_number_of_valid_trails))

    ##Analyze Plateau Characteristics
    start = datetime.datetime.now()
    print('##Analyze Plateau Characteristics(This takes a long time)')
    S.analysis_plateau_char(set_load = True, load_vec = load_vec)
    end = datetime.datetime.now()
    print(end - start)
    total_number_of_valid_trails = 0
    for idx in sorted(list(S.ana_rst_tab.keys())):
        print(idx, ":" , S.ana_rst_tab[idx])
        total_number_of_valid_trails += S.ana_rst_tab[idx]
    print("total -> ", total_number_of_valid_trails)
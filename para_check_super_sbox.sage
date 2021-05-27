import multiprocessing as mt
import pickle
import os
import datetime
import shutil
os.system("sage -preparse super_sbox_info.sage")
os.system("mv super_sbox_info.sage.py super_sbox_info.py")
from super_sbox_info  import super_sbox_dict
os.system("sage -preparse check_super_sbox.sage")
os.system("mv check_super_sbox.sage.py check_super_sbox.py")
from check_super_sbox import SuperSbox



NUM_PROCESS_THIS_SYS = mt.cpu_count() - 4
NUM_WORKLOADS        = 256
LOAD_VECS            = [None]*NUM_WORKLOADS
SUPER_SBOX_INFO      = None

def GO_PROCESS1(LOCK, PROC_NUM, RST_PATH, SHARED_INFO):
    DONE_FLAG = False
    S = SuperSbox(SUPER_SBOX_INFO[0], SUPER_SBOX_INFO[1], SUPER_SBOX_INFO[2])
    while True:
        #######################################################################
        LOCK.acquire()
        try:
            if SHARED_INFO[0] != NUM_WORKLOADS:
                pidx = int(SHARED_INFO[0])
                print("Proc %3d : Start Job"%(PROC_NUM), " (%3d)"%(pidx))
                SHARED_INFO[0]+=1
            else:
                SHARED_INFO[2]-=1
                print("Proc %3d : Finish(Waiting for %3d Proc)"%(PROC_NUM, SHARED_INFO[2]))
                DONE_FLAG = True
        finally:
            LOCK.release()
        #######################################################################
        if DONE_FLAG == True:
            break
        
        ana_rst_tab = S.analysis_plateau_char(set_load = True, load_vec = LOAD_VECS[pidx])

        with open(os.path.join(RST_PATH, "%d_ana_rst_file.pickle"%(pidx)), "wb") as f:
            pickle.dump(ana_rst_tab, f)


def GO_PROCESS2(LOCK, PROC_NUM, RST_PATH, SHARED_INFO):
    DONE_FLAG = False
    S = SuperSbox(SUPER_SBOX_INFO[0], SUPER_SBOX_INFO[1], SUPER_SBOX_INFO[2])
    while True:
        #######################################################################
        LOCK.acquire()
        try:
            if SHARED_INFO[0] != NUM_WORKLOADS:
                pidx = int(SHARED_INFO[0])
                print("Proc %3d : Start Job"%(PROC_NUM), " (%3d)"%(pidx))
                SHARED_INFO[0]+=1
            else:
                SHARED_INFO[2]-=1
                print("Proc %3d : Finish(Waiting for %3d Proc)"%(PROC_NUM, SHARED_INFO[2]))
                DONE_FLAG = True
        finally:
            LOCK.release()
        #######################################################################
        if DONE_FLAG == True:
            break
        
        valid_trails_dict = S.get_num_valid_trails(set_load = True, load_vec = LOAD_VECS[pidx])

        with open(os.path.join(RST_PATH, "%d_vaild_trails_file.pickle"%(pidx)), "wb") as f:
            pickle.dump(valid_trails_dict, f)

class SuperSboxPara:
    def __init__(self, sbox, field, matrix, left_tmp = False):
        global LOAD_VECS
        global SUPER_SBOX_INFO
        
        self.left_tmp = left_tmp

        while True:
            self.tmp_folder_path = os.path.join(".", "tmp_%s"%datetime.datetime.now().strftime("%m-%d-%H%M%S"))
            if os.path.exists(self.tmp_folder_path) == False:
                break

        SUPER_SBOX_INFO = (sbox, field, matrix)
        self.S =SuperSbox(SUPER_SBOX_INFO[0], SUPER_SBOX_INFO[1], SUPER_SBOX_INFO[2])
        
        if self.S.sboxsize == 16:
            sboxsize = 16
            for pidx in range(NUM_WORKLOADS):
                LOAD_VECS[pidx] = [None] * 4
                LOAD_VECS[pidx][0] = list(range(sboxsize))
                LOAD_VECS[pidx][1] = list(range(sboxsize))
                LOAD_VECS[pidx][2] = [int(((pidx//16).__and__(0xf)))]
                LOAD_VECS[pidx][3] = [int(((pidx//1).__and__(0xf)))]
        elif self.S.sboxsize == 256:
            sboxsize = 256
            for pidx in range(NUM_WORKLOADS):
                LOAD_VECS[pidx] = [None] * 4
                LOAD_VECS[pidx][0] = list(range(sboxsize))
                LOAD_VECS[pidx][1] = list(range(sboxsize))
                LOAD_VECS[pidx][2] = list(range(sboxsize))
                LOAD_VECS[pidx][3] = [pidx]
        else:
            raise NameError("Not Supported at the moment -> Please Contact Me")

    def analysis_plateau_char(self):
        if os.path.exists(self.tmp_folder_path) == False:    
            os.mkdir(self.tmp_folder_path)

        SHARED_INFO = mt.Array('i', [0, 0, NUM_PROCESS_THIS_SYS])
        PROCESSES = []
        LOCK = mt.Lock()
        for proc_idx in range(NUM_PROCESS_THIS_SYS):
            PROCESSES.append(mt.Process(target=GO_PROCESS1, args=(LOCK, proc_idx, self.tmp_folder_path, SHARED_INFO,)))
            PROCESSES[proc_idx].start()
        
        for proc_for_this in PROCESSES:
            proc_for_this.join()


        self.ana_rst_tab       = dict()
        for pidx in range(NUM_WORKLOADS):
            with open(os.path.join(self.tmp_folder_path, "%d_ana_rst_file.pickle"%(pidx)), "rb") as f:
                t_ana_rst_tab       = pickle.load(f)
            
            if self.left_tmp == False:
                os.remove(os.path.join(self.tmp_folder_path, "%d_ana_rst_file.pickle"%(pidx)))

            for k in t_ana_rst_tab.keys():
                if k not in self.ana_rst_tab.keys():
                    self.ana_rst_tab[k] = t_ana_rst_tab[k]
                else:
                    self.ana_rst_tab[k] += t_ana_rst_tab[k]
        
        if self.left_tmp == False:
            os.rmdir(self.tmp_folder_path)

        return self.ana_rst_tab

    def get_num_valid_trails(self):
        if os.path.exists(self.tmp_folder_path) == False:    
            os.mkdir(self.tmp_folder_path)

        SHARED_INFO = mt.Array('i', [0, 0, NUM_PROCESS_THIS_SYS])
        PROCESSES = []
        LOCK = mt.Lock()
        for proc_idx in range(NUM_PROCESS_THIS_SYS):
            PROCESSES.append(mt.Process(target=GO_PROCESS2, args=(LOCK, proc_idx, self.tmp_folder_path, SHARED_INFO,)))
            PROCESSES[proc_idx].start()
        
        for proc_for_this in PROCESSES:
            proc_for_this.join()
        
        self.valid_trails_dict = dict()
        for pidx in range(NUM_WORKLOADS):
            with open(os.path.join(self.tmp_folder_path, "%d_vaild_trails_file.pickle"%(pidx)), "rb") as f:
                t_valid_trails_dict = pickle.load(f)

            if self.left_tmp == False:
                os.remove(os.path.join(self.tmp_folder_path, "%d_vaild_trails_file.pickle"%(pidx)))

            for k in t_valid_trails_dict.keys():
                if k not in self.valid_trails_dict.keys():
                    self.valid_trails_dict[k] = t_valid_trails_dict[k]
                else:
                    self.valid_trails_dict[k] += t_valid_trails_dict[k]
        
        if self.left_tmp == False:
            os.rmdir(self.tmp_folder_path)

        return self.valid_trails_dict

if __name__ == "__main__":

    for alg in sorted(list(super_sbox_dict.keys())):
        print(alg.upper())
    ALGNAME = 'midori'#str(input("algname > "))

    #For the user
    S_PARA = SuperSboxPara(super_sbox_dict[ALGNAME.upper()]["sbox"], 
                        super_sbox_dict[ALGNAME.upper()]["field"], 
                        super_sbox_dict[ALGNAME.upper()]["matrix"],
                        left_tmp=True
                        )
    
    ##Compute Valid Trails
    print('##Compute Valid Trails')
    start = datetime.datetime.now()
    S_PARA.get_num_valid_trails()
    end = datetime.datetime.now()
    print(end-start)
    total_number_of_valid_trails = 0
    for k in sorted(list(S_PARA.valid_trails_dict.keys())):
        if k == 0:
            continue
        print("%2d : "%(k), S_PARA.valid_trails_dict[k])
        total_number_of_valid_trails+=S_PARA.valid_trails_dict[k]
    print("  --> %d"%(total_number_of_valid_trails))
    
    ##Analyze Plateau Characteristics
    print('##Analyze Plateau Characteristics(This takes a long time)')
    start = datetime.datetime.now()
    S_PARA.analysis_plateau_char()
    end = datetime.datetime.now()
    print(end-start)
    total_number_of_valid_trails = 0
    for idx in sorted(list(S_PARA.ana_rst_tab.keys())):
        print(idx, ":" , S_PARA.ana_rst_tab[idx])
        total_number_of_valid_trails += S_PARA.ana_rst_tab[idx]
    print("total -> ", total_number_of_valid_trails)
    
    '''
    #For the paper
    
    with open("pxe_class_%s.pickle"%(ALGNAME), "rb") as f:
        SBOXES  = pickle.load(f)
    
    for sidx in range(len(SBOXES)):
        sbox    = SBOXES[sidx][0]
        in_perm = SBOXES[sidx][1]
        ou_perm = SBOXES[sidx][2]
        S_PARA = SuperSboxPara(sbox, 
                                super_sbox_dict[ALGNAME.upper()]["field"], 
                                super_sbox_dict[ALGNAME.upper()]["matrix"])
        
        start = datetime.datetime.now()
        S_PARA.analysis_plateau_char()
        end = datetime.datetime.now()
        
        print("%4d "%(sidx), end-start)
        
        valid_trails_dict = dict() #None
        ana_rst_tab       = S_PARA.ana_rst_tab

        with open("%s_%d.pickle"%(ALGNAME, sidx),"wb") as f:
            pickle.dump(sbox, f)
            pickle.dump(in_perm, f)
            pickle.dump(tuple(super_sbox_dict[ALGNAME.upper()]["sbox"]), f)
            pickle.dump(ou_perm, f)
            pickle.dump(valid_trails_dict, f)
            pickle.dump(ana_rst_tab, f)
            pickle.dump(end - start, f)
    '''
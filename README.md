# CISC_Plateau_Characteristic
## Requirements
1. python 3.x
2. SageMath 9.3 version 
    http://www.sagemath.org/
    
## Informtation
### How to use
1. Enter the directory
2. Command "sage para_check_super_sbox.sage" or "sage check_super_sbox.sage"
   2-1 para_check_super_sbox.sage : forks a proper number of processes to the current system. 
   2-2 check_super_sbox.sage      : forks only a single process.
   >> Using the 2-1 method is preferred.
3. Choose the block cipher

### To add more combinations of S-Box and Matrix,
Add the information with the proper format to ./super_sbox_info.sage
(e.g., 
    super_sbox_dict["ALGNAME"] = {
       "sbox" :
       [ S-box LUT],
       "field" :
       [ the field for the matrix multiplications],
       "matrix" :
       [ Matrix for mixcolumns]
    }
)

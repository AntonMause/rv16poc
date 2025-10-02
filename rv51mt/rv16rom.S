# ------------------------------------------------------------------------
# file rv16rom.S   (c) 2019 by Anton Mause
# ------------------------------------------------------------------------
#ifndef RV16ROM_S
#define RV16ROM_S

#include "encoding.h"
# ------------------------------------------------------------------------
  .section      .text.entry
  .globl _start
# ------------------------------------------------------------------------
_start:

jmp0:  addi  x2, x0, 2    # $00
jmp1:  jal   x1, jmp3     # $04
jmp2:  jalr  x2, x1, 0    # $08
jmp3:  bge   x2, x1, jmp1 # $0C
jmp4:  j     jmp2         # $10
jmp5:  j     jmp7
jmp6:  j     jmp4
jmp7:  j     jmp9
jmp8:  j     jmp6
jmp9:  j     jmp8

#jmp0:  addi  x0, x0, 0    # $00 nop
#jmp1:  j     jmp3         # $04
#jmp2:  j     jmp0         # $08
#jmp3:  j     jmp5         # $0C
#jmp4:  j     jmp2         # $10
#jmp5:  j     jmp7
#jmp6:  j     jmp4
#jmp7:  j     jmp9
#jmp8:  j     jmp6
#jmp9:  j     jmp8


# ------------------------------------------------------------------------

#endif

# could use 1: as label and 1f as forward reference in as/gcc/ld
# but not in this emulator : https://www.kvakil.me/venus/


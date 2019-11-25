# ------------------------------------------------------------------------
# file rv16rom.S   (c) 2019 by Anton Mause
# ------------------------------------------------------------------------
#ifndef RV16ROM_S
#define RV16ROM_S

#include "encoding.h"
# ------------------------------------------------------------------------
# t0 = shift register, current value for gpo
# t1 = temp variable, gpi or flag, ...
#
# g4/5 = rv16gpo and this rv16rom can synthesise as low as 300 LUT4
# ------------------------------------------------------------------------
  .section      .text.entry
  .globl _start

# ------------------------------------------------------------------------
_start:

# ------------------------------------------------------------------------
# initialize shift register
    addi  t0, x0, 1
main_loop:
    sh    t0, 0(x0)
    slli  t0, t0, 1
    andi  t0, t0, 255
	bne   t0, x0, sl1
    addi  t0, x0, 1
sl1:j     main_loop

# ------------------------------------------------------------------------

#endif

# online emulator : https://www.kvakil.me/venus/

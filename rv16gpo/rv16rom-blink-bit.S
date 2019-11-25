# ------------------------------------------------------------------------
# file rv16rom.S   (c) 2019 by Anton Mause
# ------------------------------------------------------------------------
#ifndef RV16ROM_S
#define RV16ROM_S

#include "encoding.h"
# ------------------------------------------------------------------------
# t0 = shift register, current value for gpo
#
# g4/5 = rv16gpo and this rv16rom can synthesise as low as 240 LUT4
#        if trimmed pcu to 6 bit and synthesed with 25MHz target frequency
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
    xori  t0, t0, 1
    beq   x0, x0, main_loop	

# ------------------------------------------------------------------------

#endif

# online emulator : https://www.kvakil.me/venus/

# ------------------------------------------------------------------------
# file rv16rom.S   (c) 2019 by Anton Mause
# ------------------------------------------------------------------------
#ifndef RV16ROM_S
#define RV16ROM_S

#include "encoding.h"
# ------------------------------------------------------------------------
# t0 = shift register, current value for gpo
# t1 = copy of gpi = current push buttons input
# search for ... to see effect of modifications
# ------------------------------------------------------------------------
  .section      .text.entry
  .globl _start

# ------------------------------------------------------------------------
_start:

# ------------------------------------------------------------------------
# initialize shift register
    addi  t0, x0, 1  # one bit...
#   addi  t0, x0, 15 # ...or more
main_loop:
    sh    t0, -1(x0)
check_pb:
# check if any push button (pb) pressed
    lh    t1, -1(x0)
    andi  t1, t1, 3
	bne   t1, x0, shift_right
# no pb pressed, shift left
shift_left:
    slli  t0, t0, 1   # original shift
#   add   t0, t0, t0  # same result for #1
    andi  t0, t0, 255
# check if shift register is empty
	bne   t0, x0, sl1
    addi  t0, x0, 1
sl1:j     main_loop
# some pb is pressed
shift_right:
    srli  t0, t0, 1
# check if shift register is empty
	bne   t0, x0, sr1
#   addi  t0, x0, 128 # single bit...
    addi  t0, x0, 255 # ...or all
sr1:j     main_loop

# ------------------------------------------------------------------------

#endif

# could use 1: as label and 1f as forward reference in as/gcc/ld
# but not in this emulator : https://www.kvakil.me/venus/

#   addi  t0, x0, 1  # one bit...
    addi  t0, x0, 15 # ...or more
    addi  t1, x0, 255
main_loop:
#    sh    t0, -1(x0)
    add   t0, t0, t0
#    sh    t0, -1(x0)
    add   t0, t0, t0
#    sh    t0, -1(x0)
    xori   t0, t0, 255
#    sh    t0, -1(x0)
# check if shift register is empty
	blt   t0, t1, sr1
    addi  t0, x0, 15
sr1:j     main_loop


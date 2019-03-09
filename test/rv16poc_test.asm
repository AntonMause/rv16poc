
Online Assembler
http://www.kvakil.me/venus/

Online ISA
https://rv8.io/isa.html


one:
    lui     x3, 76543
    auipc   x2, 0
    jal     x1, two
    jal     x0, two
two:
    addi	x0, x0, 0
    sh		x1, 0(x3)
    lh		x4, 0(x3)
    sh		x2, 0(x3)
    lh		x5, 0(x3)
    jalr    x1, x2, 0
    jalr    x0, x0, 0
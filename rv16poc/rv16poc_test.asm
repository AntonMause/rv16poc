
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





zero:
	addi	x6, x0, +1
    addi	x5, x0, -1
    lui		x3, 0x55555
    addi	x3, x3, 0x555

one:
	jal		x1, one2f
one1b:
    addi	x1, x2, 0
one2f:
    auipc	x2, 0
    bne		x1, x2, one1b

two:
    addi	x4, x0, -256
    srli	x4, x4, 24		# to emulate rv16
    slli	x4, x4, 8
two1b:
    srli	x4, x4, 3
	sh		x4, 0(x0)
    bltu	x4, x0, two1b
    
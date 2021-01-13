_start:
        # Load some constants and do some arithmetic
        # li a0, 0
        # li a1, 1
        # li a2, 2
        # li a3, 3
        # li a4, 4
        # li a5, 5
        # li a6, 6
        # li a7, 7
        # add t0, a1, a2
        # add t1, a3, a4
        # add t2, a4, a5
        # add t0, t1, t2
        li a0, 65535
        csrrs zero, 0x7A0, a0
        li a0, 0
        li a1, 1
        li a2, 2
        li a3, 3
        li a4, 4
        li a5, 5
        li a6, 6
        li a7, 7

        .insn i 0x0b, 0, x0, a1, 0 # upper a0, a1
        .insn i 0x0b, 0, a2, a7, 0 # upper a2, a7
        .insn i 0x0b, 1, a3, a4, 0 # lower a3, a4
        .insn i 0x0b, 2, a4, a5, 0 # leet  a4, a5
        .insn i 0x0b, 3, a5, a1, 0 # rot13 a5, a1

        li a1, 0x74657374       # al = "test"
        .insn i 0x0b, 0, a0, a1, 0 # upper a0, a1

        li a5, 0x74657374       # test
        li a6, 0x6c656574       # leet
        .insn i 0x0b, 2, a4, a5, 0 # leet a4, a5
        .insn i 0x0b, 2, a5, a6, 0 # leet a5, a6
        .insn i 0x0b, 3, a7, a6, 0 # rot13 a7, a6

        # add 1 to 10
        li      a0, 0
        li      a4, 0
        li      a2, 10
        li      a3, 0

loop:   
        add     a4, a3, a4
        addi    a3, a3, 1
        blt     a3, a2, loop
        add     a0, a4, zero




exit:
        # Similar to exit(0) in C.
        li a0, 0
        li a1, 0
        li a2, 0
        li a7, 93
        ecall

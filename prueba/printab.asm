	.module printab

	.area	_CODE (REL,CON)

	.globl print_a
        .globl print_b
print_a:lda #'A
	sta 0xFF00
        rts
print_b:lda #'B
        sta 0xFF00
        rts

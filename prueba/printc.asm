	.module printc

	.area	_CODE (REL,CON)

	.globl print_c
print_c:lda #'C
	sta 0xFF00
        rts

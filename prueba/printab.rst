ASxxxx Assembler V05.00  (Motorola 6809), page 1.
Hexidecimal [16-Bits]



                              1 	.module printab
                              2 
                              3 	.area	_CODE (REL,CON)
                              4 
                              5 	.globl print_a
                              6         .globl print_b
   0000 86 41         [ 2]    7 print_a:lda #'A
   0002 B7 FF 00      [ 5]    8 	sta 0xFF00
   0005 39            [ 5]    9         rts
   0006 86 42         [ 2]   10 print_b:lda #'B
   0008 B7 FF 00      [ 5]   11         sta 0xFF00
   000B 39            [ 5]   12         rts
ASxxxx Assembler V05.00  (Motorola 6809), page 2.
Hexidecimal [16-Bits]

Symbol Table

    .__.$$$.       =   2710 L   |     .__.ABS.       =   0000 G
    .__.CPU.       =   0000 L   |     .__.H$L.       =   0001 L
  0 print_a            0000 GR  |   0 print_b            0006 GR

ASxxxx Assembler V05.00  (Motorola 6809), page 3.
Hexidecimal [16-Bits]

Area Table

[_CSEG]
   0 _CODE            size    C   flags CD80
[_DSEG]
   1 _DATA            size    0   flags C0C0


ASxxxx Assembler V05.00  (Motorola 6809), page 1.
Hexidecimal [16-Bits]



                              1 	.module prueba
                              2 
                              3 	.area CODE1 (ABS)
                              4 
   0000                       5 	.org 0x0000
                              6 	.globl programa
                              7         .globl print_a
                              8         .globl print_b
                              9         .globl print_c
                             10 
   0000                      11 programa:
   0000 10 CE F0 00   [ 4]   12         lds #0xF000
   0004 BD 00 00      [ 8]   13         jsr print_a
   0007 BD 00 06      [ 8]   14         jsr print_b
   000A BD 00 0C      [ 8]   15         jsr print_c
   000D 4F            [ 2]   16 	clra
   000E B7 FF 01      [ 5]   17 	sta 0xFF01
                             18 
                             19 	.area FIJA (ABS)
   FFFE                      20 	.org 0xFFFE
   FFFE 00 00                21 	.word programa
ASxxxx Assembler V05.00  (Motorola 6809), page 2.
Hexidecimal [16-Bits]

Symbol Table

    .__.$$$.       =   2710 L   |     .__.ABS.       =   0000 G
    .__.CPU.       =   0000 L   |     .__.H$L.       =   0001 L
    print_a            **** GX  |     print_b            **** GX
    print_c            **** GX  |   2 programa           0000 GR

ASxxxx Assembler V05.00  (Motorola 6809), page 3.
Hexidecimal [16-Bits]

Area Table

[_CSEG]
   0 _CODE            size    0   flags C080
   2 CODE1            size   11   flags  908
   3 FIJA             size    0   flags  908
[_DSEG]
   1 _DATA            size    0   flags C0C0


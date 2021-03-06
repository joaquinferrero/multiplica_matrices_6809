;
; Multiplicación de dos matrices 3x3
;
; Joaquín Ferrero. 21 mayo 2014.
;
; v4. Versión para LWTools
;
; Última versión: 20180214T2215
;
; Propósito:
;        Se realiza la multiplicación de dos matrices.
;
; Definiciones:
;        Una matriz es un conjunto de datos, ordenado por
;                filas (primera dimensión), y
;                columnas (segunda dimensión).
;
; Entrada:
;        Las matrices de entrada y la de resultado estarán compuestas de octetos.
;        Las dimensiones de las matrices de entrada deben ser coherentes para poder
;        realizar la multiplicación (D2(M1) == D1(M2), D(M3) = D1(M1) * D2(M2)).
;
; Código para lwasm (lwtools)
; ---------------------------------------------------------------------------

; Cálculo de las dimensiones de las matrices
DIM1C           equ     m11-m1
DIM2C           equ     m21-m2
DIM1F           equ     (m2-m1)/DIM1C
DIM2F           equ     (m3-m2)/DIM2C

; Llamada a la subrutina

                org     $0000
                setdp   0                       ; cuando se inicia, la cpu tiene DP = 0

; Programa: ejemplo de llamada a la subrutina

                LDX     #m1                     ; apuntamos a base de las matrices
                LDY     #m2
                LDU     #m3                     ; puntero U apunta a matriz resultado

                LDA     #DIM1F*16+DIM1C         ; dimensiones (BCD) de la primera matriz
                LDB     #DIM2F*16+DIM2C         ; dimensiones (BCD) de la segunda matriz

                JSR     >matmul

                BRA     *                       ; bucle infinito

; Ejemplo: matrices a multiplicar
m1              .db     9,6,3                   ; matriz primera
m11             .db     8,5,2
                .db     7,4,1
                .db     10,3,0
                .db     11,2,4
                .db     12,0,7
;
m2              .db     1,2,3,4,5               ; matriz segunda
m21             .db     4,5,6,7,8
                .db     7,8,9,10,11

; Matriz resultado
m3              zmb     DIM1F*DIM2C             ; espacio relleno con ceros


; ---------------------------------------------------------------------------
; Subrutina de multiplicación
;
; Registros modificados:
;        Todos, menos U
;
; Entrada:
;        X: puntero a la primera matriz
;        Y: puntero a la segunda matriz
;        U: puntero al espacio reservado para la matriz resultado
;        A: dimensiones (en BCD) de la primera matriz
;        B: dimensiones (en BCD) de la segunda matriz
;
; Salida:
;        U: apunta al resultado, poblado por D1(M1)*D2(M2) octetos.
;        A: resultado de la ejecución
;                0: no hubo error. En el espacio apuntado anteriormente por U
;                1: las dimensiones de las matrices no son coherentes
;                2: hubo desbordamiento de octeto en un resultado, y se paró el proceso
;

                org     $2000
                align   100h                    ; error con el JSR anterior, si se activo esto
;
matmul:

; Salvar registros
                PSHS    U,DP

; Inicializar DP
                PSHS    D                       ; guardamos la dimensiones un momento
                TFR     PC,D                    ; obtenemos la página en donde estamos
                TFR     A,DP                    ; la guardamos en el registro DP, para hacer código más corto
                PULS    D                       ; recuperar dimensiones

                setdp   */256                   ; valor de DP para el ensamblador

; Almacenar las dimensiones de las matrices
                PSHS    A                       ; guardamos la dimensiones un momento
                ANDA    #0Fh                    ; segunda dimensión de la primera matriz
                STA     dimM1+1                 ; guardar
                PULS    A                       ; recuperamos las dimensiones
                LSRA
                LSRA
                LSRA
                LSRA                            ; primera dimensión de la primera matriz
                STA     dimM1                   ; guardar

                PSHS    B                       ; lo mismo para la segunda matriz
                ANDB    #0Fh
                STB     dimM2+1                 ; segunda dimensión de la segunda matriz
                PULS    B
                LSRB
                LSRB
                LSRB
                LSRB
                STB     dimM2                   ; primera dimensión de la segunda matriz

                STY     ptrM2                   ; almacén del puntero a segunda matriz

; Comprobación de las dimensiones
                LDA     dimM1+1                 ; segunda dimensión de la primera matriz
                CMPA    dimM2                   ; primera dimensión de la segunda matriz
                BEQ     matmulinicio

                LDA     #1                      ; ERROR en las dimensiones
                JMP     matmulsalida

; Inicializar contadores
matmulinicio:
                LDA     dimM1                   ; filas a recorrer
                STA     rows

; Precálculo de desplazamientos por la matriz
                LDA     dimM2                   ; diferencias entre filas en primera matriz
                NEGA
                STA     difrows
                LDB     dimM2+1                 ; diferencias entre columnas en segunda matriz
                MUL
                INCB
                STB     difcols

; Bucle por las filas
matmulL2:
                LDY     ptrM2                   ; reposicionamos puntero a segunda matriz

                LDA     dimM2+1                 ; columnas a recorrer
                STA     cols

; Bucle por las columnas
matmulL1:
                CLR     acumula                 ; limpiamos acumulador
                CLR     acumula+1

                LDA     dimM2                   ; dimensión común
                STA     c

; Bucle del sumatorio de los productos
matmulL0:
                LDA     ,X                      ; leer dato de la fila en primera matriz
                LDB     ,Y                      ; leer dato de la columna en segunda matriz

                MUL                             ; multiplicar

                ADDD    acumula                 ; y sumar
                STD     acumula                 ; al acumulador
;
                TSTA                            ; comprobar octeto superior
                BEQ     matmulN                 ; sí, todo va Normal
                LDA     #2                      ; ERROR, hubo un desborde de octeto, salir
                JMP     matmulsalida
;
matmulN:
                LEAX    1,X                     ; apuntamos a siguiente dato en fila
                LDA     dimM2+1
                LEAY    A,Y                     ; apuntamos a siguiente dato en columna
;
                DEC     c                       ; repetimos
                BNE     matmulL0
;
                STB     ,U+                     ; guardar resultado
;
                LDA     difrows                 ; reposicionamos puntero a fila
                LEAX    A,X
                LDA     difcols                 ; reposicionamos puntero a columna
                LEAY    A,Y
;
                DEC     cols                    ; siguiente columna
                BNE     matmulL1                ; repetir para todas las columnas
;
                LDA     dimM1+1
                LEAX    A,x                     ; reposicionamos puntero a siguiente fila
;
                DEC     rows                    ; siguiente fila
                BNE     matmulL2                ; repetir para todas las filas
;
                LDA     #0                      ; salida sin errores
;               JMP     matmulsalida

; Salida
matmulsalida:
                PULS    U,DP
                RTS

; Variables
ptrM2           .ds     2                       ; almacén puntero a la segunda matriz
dimM1           .ds     2                       ; dimensiones de la primera matriz
dimM2           .ds     2                       ; dimensiones de la segunda matriz
acumula         .ds     2                       ; acumulador (sumatorio) de los productos
difcols         .ds     1                       ; diferencia entre columnas de la segunda matriz
difrows         .ds     1                       ; diferencia entre filas de la primera matriz
rows            .ds     1                       ; contador para las filas
cols            .ds     1                       ; contador para las columnas
c               .ds     1                       ; contador para cada elemento de la matriz resultado
; ---------------------------------------------------------------------------

                END

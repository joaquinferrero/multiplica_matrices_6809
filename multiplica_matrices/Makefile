
#
# Makefile para multiplica_matrices
#

# Archivos del proyecto
PROJECT		= multiplica_matrices

SOURCE		= $(PROJECT).asm
TARGET		= $(PROJECT).s19

OTHERS		= constantes.asm

LIBS		= matmul.asm

LIBS_FILE	= IO.lib
LIBS_SOURCES	= IO_print.asm IO_print_numero.asm IO_read_row.asm

EXTRA_FILES	= plantilla.asm test.txt out.txt Makefile

SOURCES		= $(SOURCE) $(LIBS) $(LIBS_SOURCES)
OBJECTS		= $(SOURCE:asm=rel) $(LIBS:asm=rel)

SOURCES_ALL	= $(SOURCES) $(OTHERS) $(LIBS_FILE)
OBJECTS_ALL	= $(SOURCES:asm=rel)

# Herramientas
ASSEMBLER=./as6809
LINKER=./aslink
SIMULATOR=./m6809-run

# Opciones de ejecución
OPT_AS_TEST=
OPT_AS=-x -l -o -s -w -p
OPT_AL=-n -m -w -x -s -o -u -b CODE_MATMUL=0x0400


# Reglas
all: $(TARGET)

$(TARGET) : $(OBJECTS_ALL) $(OTHERS) $(LIBS_FILE)

# Ensamblar
%.rel : %.asm $(OTHERS)
	@echo "Compilando..."
	$(ASSEMBLER) $(OPT_AS_TEST) $<
	$(ASSEMBLER) $(OPT_AS)      $<
	@echo "Ok"

# Enlazar
%.s19 : %.rel
	@echo "Enlazando..."
	$(LINKER) $(OPT_AL) $@ $(OBJECTS) -l $(LIBS_FILE)
	@echo "Ok"

# Ejecuta
run: $(TARGET)
	$(SIMULATOR) $(TARGET)

# Test
test: $(TARGET)
	@$(SIMULATOR) $(TARGET) < test.txt

# Comprobación
check: $(TARGET)
	@$(SIMULATOR) $(TARGET) < test.txt > $(PROJECT).txt
	@diff -s $(PROJECT).txt out.txt

# Editar las fuentes
joe:
	@joe $(SOURCES) $(OTHERS)

# Limpiar directorio
clean:
	@rm -f $(SOURCES:asm=asm~) $(OTHERS:asm=asm~)
	@rm -f $(SOURCES:asm=rel) $(SOURCES:asm=lst) $(SOURCES:asm=rst) $(SOURCES:asm=sym)
	@rm -f $(SOURCE:asm=map)

clean_all: clean
	@rm -f $(TARGET)

# Estadísticas
stats:
	@wc -l $(SOURCES_ALL) $(EXTRA_FILES)

# Comprime
compress:
	zip -uo $(PROJECT).zip $(TARGET) $(ASSEMBLER) $(LINKER) $(SIMULATOR) $(SOURCES_ALL) $(EXTRA_FILES)

# [Tab=8. UTF-8]
#

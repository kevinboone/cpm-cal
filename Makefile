
# Set the path to the CPM emulator. 
# Obtain it from here: https://github.com/jhallen/cpm
CPM=cpm

# Define the assembler and linker. Get Macro80 and Link80 from here:
# http://www.retroarchive.org/cpm/lang/m80.com
# http://www.retroarchive.org/cpm/lang/l80.com
MACRO80=m80
LINK80=l80

NAME=cal
TARGET=cal.com

all: $(TARGET)

main.rel: main.asm conio.inc intmath.inc clargs.inc date.inc romwbw.inc
	$(CPM) $(MACRO80) =main.asm

conio.rel: conio.asm bdos.inc
	$(CPM) $(MACRO80) =conio.asm

mem.rel: mem.asm
	$(CPM) $(MACRO80) =mem.asm

intmath.rel: intmath.asm 
	$(CPM) $(MACRO80) =intmath.asm

string.rel: string.asm intmath.inc
	$(CPM) $(MACRO80) =string.asm

date.rel: date.asm intmath.inc
	$(CPM) $(MACRO80) =date.asm

clargs.rel: clargs.asm mem.inc
	$(CPM) $(MACRO80) =clargs.asm

romwbw.rel: romwbw.asm romwbw.inc
	$(CPM) $(MACRO80) =romwbw.asm

$(TARGET): conio.rel main.rel intmath.rel string.rel mem.rel clargs.rel date.rel romwbw.rel
	$(CPM) $(LINK80) main,$(NAME)/n/e

clean:
	rm -f $(TARGET) *.rel



all: rename.bin

lbr: rename.lbr

clean:
	rm -f rename.lst
	rm -f rename.bin
	rm -f rename.lbr

rename.bin: rename.asm include/bios.inc include/kernel.inc
	asm02 -L -b rename.asm
	rm -f rename.build

rename.lbr: rename.bin
	rm -f rename.lbr
	lbradd rename.lbr rename.bin


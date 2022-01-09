ARCH=i686-elf
CXX=@/opt/cross/$(ARCH)/bin/$(ARCH)-g++
CC=@/opt/cross/$(ARCH)/bin/$(ARCH)-gcc
AS=@/opt/cross/$(ARCH)/bin/$(ARCH)-as
LD=@/opt/cross/$(ARCH)/bin/$(ARCH)-gcc
NAME=PrismOS

VERSION=$(shell git rev-parse --short HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
CXXFLAGS=-Isrc/inc -fno-use-cxa-atexit -DNAME=\"$(NAME)\" -DVERSION=\"$(VERSION)\" -DBRANCH=\"$(BRANCH)\" -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -Wno-write-strings -Wno-unused-variable -w -Wno-narrowing -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-missing-field-initializers
CFLAGS=-Isrc/inc -fno-use-cxa-atexit -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -Wno-write-strings -Wno-unused-variable -w -Wno-narrowing -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-missing-field-initializers
NASM=nasm
ASFLAGS=-felf32
CXX_SOURCES=$(shell find . -name '*.cpp')
C_SOURCES=$(shell find . -name '*.c')
LINK_SOURCES=$(shell find . -name '*.o')
CPP_FILES_OUT = $(CXX_SOURCES:.cpp=.o)
C_FILES_OUT = $(C_SOURCES:.c=.o)

all: as $(C_FILES_OUT) $(CPP_FILES_OUT) link clean_objects grub run
as:
	$(AS) -32 'Source/etc/boot.s' -o 'Source/bin/boot.a'
link:
	$(LD) -w -T 'Source/etc/linker.ld' -o 'Source/bin/PrismOS.bin' -ffreestanding -O2 -nostdlib 'Source/bin/boot.a' $(LINK_SOURCES)     

run:
	@qemu-system-i686 -cdrom Source/bin/PrismOS.bin -boot d -serial stdio -vga std -enable-kvm -no-reboot -no-shutdown -d int -m 4096

clean:
	@-rm -Rf $(shell find . -name '*.o') $(shell find . -name '*.bin') $(shell find . -name '*.iso')

clean_objects:
	@-rm -Rf $(shell find . -name '*.o') $(shell find . -name '*.a') 

grub:
	@mkdir -p Source/ISO/boot/grub
	@cp Source/bin/PrismOS.bin Source/ISO/boot
	@cp Source/etc/grub.cfg Source/ISO/boot/grub/grub.cfg
	@grub-mkrescue -o PrismOS.iso Source/ISO/

run-kernel:
	@qemu-system-i386 -kernel kernel.bin -serial stdio --enable-kvm -vga std -no-reboot -no-shutdown -d int

bochs:
	@bochs -q -f bochsrc.txt

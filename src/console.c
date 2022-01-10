#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "string.c"

/* Hardware text mode color constants. */
enum vga_color {
	BLACK = 0,
	BLUE = 1,
	GREEN = 2,
	CYAN = 3,
	RED = 4,
	MAGENTA = 5,
	BROWN = 6,
	LIGHT_GREY = 7,
	DARK_GREY = 8,
	LIGHT_BLUE = 9,
	LIGHT_GREEN = 10,
	LIGHT_CYAN = 11,
	LIGHT_RED = 12,
	LIGHT_MAGENTA = 13,
	LIGHT_BROWN = 14,
	WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

static const size_t WIDTH = 80;
static const size_t HEIGHT = 25;

size_t Row;
size_t Column;
uint8_t TColor;
uint16_t* Buffer;

void Initialize(void)
{
	Row = 0;
	Column = 0;
	TColor = vga_entry_color(LIGHT_GREY, BLACK);
	Buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < HEIGHT; y++) {
		for (size_t x = 0; x < WIDTH; x++) {
			const size_t index = y * WIDTH + x;
			Buffer[index] = vga_entry(' ', TColor);
		}
	}
}

void setcolor(uint8_t color)
{
	TColor = color;
}

void putentryat(char c, uint8_t Color, size_t x, size_t y)
{
	const size_t index = y * WIDTH + x;
	Buffer[index] = vga_entry(c, Color);
}

void putchar(char c)
{
	putentryat(c, TColor, Column, Row);
	if (++Column == WIDTH) {
		Column = 0;
		if (++Row == HEIGHT)
			Row = 0;
	}
}

void Write(const char* str)
{
	for (size_t i = 0; i < LengthOf(str); i++)
	{
		if(str[i] == '\n')
		{
			Column = 0;
			Row++;
		}
		else if (str[i] == '\t')
		{
			Write("    ");
		}
		else
		{
			putchar(str[i]);
		}
	}
}

void WriteLine(const char* str)
{
	Write(str);
	Write("\n");
}

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "console.c"

void Main(void)
{
	Initialize();
	WriteLine("Hello, World!");
	WriteLine("Amogoos");
	Write("Testing of tab!");
	WriteLine("\tWorks!");
}

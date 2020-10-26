#include <string>
#include <iostream>
#include <fstream>
#include <cstdint>
#include <vector>
#include <iomanip>
#include "codegen.hpp"
// Generate: generates a VHDL package, which contains
//	- RAM type declerations
//	- 4 initializer lists. 1 for each byte in a word
// First we generate the byte address pairs into a temporary string
// Then we print the header, which declares the package and types
// Then we print each buffer, with the byte array header.
// Then the prologue is printed
// The package can then be used to initialize memory_t typed 1 byte wide memory arrays
void VHDLGenerator::generate(std::vector<uint8_t> vec)
{
	uint16_t offset=0;
	
	//Set fill character
	buffer[0].fill('0');
	buffer[1].fill('0');
	buffer[2].fill('0');
	buffer[3].fill('0');
	
	// Generate buffers
	for(auto byte : vec)
	{
		buffer[offset%4] << "\t\t" << std::dec << offset/4 << " => X\"" << std::hex << std::setw(2) << (unsigned)byte << "\",\n";
		offset++;
	}
	
	// Print Header
	*stream << "LIBRARY IEEE;\n";
	*stream << "USE IEEE.std_logic_1164.ALL;\n";
	*stream << "PACKAGE memory_package IS\n";

	*stream << "\tCONSTANT ADDR_WIDTH : integer	:= 14;\n";
	*stream << "\tSUBTYPE word_t IS std_logic_vector(7 DOWNTO 0);\n";
	*stream << "\tTYPE memory_t IS ARRAY(2**ADDR_WIDTH-1 DOWNTO 0) OF word_t;\n";
	
	// Print initializer lists
	for(int i=0;i<4;i++)
	{
		*stream << "\tconstant ROM" << i << " : memory_t :=\n";
		*stream << "\t(\n";
		*stream << buffer[i].str();
		*stream << "\t\tothers => X\"0" << i << "\"\n";
		*stream << "\t);\n";
	}
	
	// Print prologue
	*stream << "END PACKAGE memory_package;\n";
	*stream << "PACKAGE BODY memory_package IS\n";
	*stream << "END PACKAGE BODY memory_package;\n";
	*stream << std::endl;
}
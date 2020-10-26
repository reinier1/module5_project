#ifndef CODEGEN_HPP
#define CODEGEN_HPP
#include <string>
#include <iostream>
#include <cstdint>
#include <vector>
#include <sstream>

/*******************************************************************************
** VHDLGenerator Definition
** Contains:
**	- pointer to output stream.(Not owned by VHDLGenerator)
**	- 4 buffers to store one byte of the 4-byte memory each
** Implements:
**	- Generate to turn a list of bytes into a VHDL memory package
*******************************************************************************/

class VHDLGenerator
{
public:
	VHDLGenerator(std::ofstream &output) : stream{&output} {};
	void generate(std::vector<uint8_t> vec);
private:
	std::ofstream *stream;
	std::stringstream buffer[4];
};
#endif
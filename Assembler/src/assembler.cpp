#include <cstdint>
#include <vector>
#include <iostream>
#include <iomanip>
#include "tokens.hpp"
#include "ast.hpp"
#include "symbol_table.hpp"
#include "assembler.hpp"

/*******************************************************************************
** Assembler class implementation
** Contains
**	- Public method, which returns a fully assembled array of bytes
** 	- Public callback operators, which fill the array with new instruction/data
**	- Public helper methods
**      - align inserts alignment bytes
**      - tok2op returns the opcode corresponding to a specific instruction
**      - fit_imm returns the 16-bit signed immediate version of an integer
**      - ins_is_mem returns wether an instruction accesses memory
**	- Public method to print the internal array 
*******************************************************************************/

// assembler(AST) -> list of bytes
// Foreach line assemble the instruction 
// Return byte list
std::vector<uint8_t> Assembler::assemble(std::vector<ASTLine> &lines,SymbolTable &symtab)
{
	for(auto &it : lines)
	{
		it.instruction->assemble(*this,symtab);
	}
	return output;
}

// operator<<(byte)
// Append byte to output array
Assembler &Assembler::operator<<(uint8_t data)
{
	output.push_back(data);
	offset+=1;
	return *this;
}

// operator<<(16-bit unsigned int) 
// Align offset two 2 bytes
// Append bytes Little Endian to output array
Assembler &Assembler::operator<<(uint16_t data)
{
	align(offset,2);
	output.push_back((data>>0)&0xff);
	output.push_back((data>>8)&0xff);
	offset+=2;
	return *this;
}

// operator<<(32-bit unsigned int) 
// Align offset two 4 bytes
// Append bytes Little Endian to output array
Assembler &Assembler::operator<<(uint32_t data)
{
	align(offset,4);
	output.push_back((data>>0)&0xff);
	output.push_back((data>>8)&0xff);
	output.push_back((data>>16)&0xff);
	output.push_back((data>>24)&0xff);
	offset+=4;
	return *this;
}

// align(16-bit unsigned int, 16-bit unsigned int) -> 32-bit unsigned int
// Calculate new alignment
// Foreach byte neccessary to achieve alignment 
//	- append 0 byte to output array
uint16_t Assembler::align(uint16_t &loc,uint16_t alignment)
{
	uint16_t old_loc=loc;
	::align(loc,alignment);
	for(uint16_t i=0;i<(loc-old_loc);i++)
		output.push_back(0);
	return loc;
}

// fit_imm(32-bit signed int, instruction type) -> 16-bit unsigned int
// If instruction does not acces memory check if value fits
// Return first 16-bits of output
uint16_t Assembler::fit_imm(int32_t val,TOK type)
{
	if(!ins_is_mem(type))
	{
		if(val<-(1<<15)||val>((1<<15)-1))
		{
			std::cerr<<"Error: "<<val<<"does not fit into 16-bit signed immediate\n";
		}
	}
	return val&0xffff;
}

// tok2op(token type) -> 32-bit unsigned int
// Look up the instruction and return the corresponding opcode bit pattern
uint32_t Assembler::tok2op(TOK tok)
{
	switch(tok)
	{
		case TOK::ADD: 	return 0b00000;
		case TOK::SUB: 	return 0b00001;
		case TOK::MUL: 	return 0b00010;
		case TOK::AND: 	return 0b00011;
		case TOK::OR: 	return 0b00100;
		case TOK::XOR: 	return 0b00101;
		case TOK::SLA: 	return 0b00110;
		case TOK::SRA: 	return 0b00111;
		case TOK::BEQ:	return 0b01000;
		case TOK::BNE:	return 0b01001;
		case TOK::BLT: 	return 0b01010;
		case TOK::BLTU:	return 0b01011;
		case TOK::LW: 	return 0b10000;
		case TOK::LB: 	return 0b10001;
		case TOK::SW:	return 0b10100;
		case TOK::SB:	return 0b10101;
		case TOK::MOVE:	return 0b11000;
		case TOK::JP: 	return 0b11100;
		default:
			std::cerr<<"Internal Error: Bad token\n";
			return tok2op(TOK::ADD);
	}
}

// ins_is_mem(token type) -> boolean
// If this instruction references memory return true else return false
// For instructions that access memory, it does not matter if the immediate would not fit
// The address space is limited to 16-bits anyway
bool Assembler::ins_is_mem(TOK type)
{
	switch(type)
	{
		case TOK::ADD: 	
		case TOK::SUB: 	
		case TOK::MUL: 	
		case TOK::AND: 	
		case TOK::OR: 	
		case TOK::XOR: 	
		case TOK::SLA: 	
		case TOK::SRA: 	
			return false;
			
		case TOK::BEQ:
		case TOK::BNE:
		case TOK::BLT: 	
		case TOK::BLTU:	
		case TOK::LW: 	
		case TOK::LB: 	
		case TOK::SW:	
		case TOK::SB:	
			return true;
			
		case TOK::MOVE:	
			return false;
			
		case TOK::JP: 	
			return true;
			
		default:
			std::cerr<<"Internal Error: Bad token\n";
			return false;
	}
}

// Print assembler output
//	- Safe all output flags
//	- Set output flags to hex
// 	- Foreach byte 
//	   - If word aligned print word address and new line
//	   - Print byte
//	- Append end line
//	- Restore all output flags
std::ostream &operator<<(std::ostream &stream,Assembler &assembler)
{
	uint16_t offset=0;
	
	auto flags=stream.flags();
	auto fill=stream.fill();
	auto width=stream.width();
	
	stream<<std::hex<<std::setfill('0');
	
	for(auto it : assembler.output)
	{
		if(offset%4==0)
			stream << "\n" << std::setw(4) << offset << ": " << std::setw(2);
		stream << std::setw(2) << (unsigned int)it << " ";
		offset+=1;
	}
	stream<<std::endl;
	
	stream.flags(flags);
	stream.fill(fill);
	stream.width(width);
	
	return stream;
}
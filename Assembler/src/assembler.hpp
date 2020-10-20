#ifndef ASSEMBLER_HPP
#define ASSEMBLER_HPP
#include <cstdint>
#include <vector>
#include <iostream>
#include "tokens.hpp"
#include "ast.hpp"
#include "symbol_table.hpp"

/*******************************************************************************
** Contains the constants for all specific instruction component location
** Assembler class definition
** Contains
**	- Public method, which returns a fully assembled array of bytes
** 	- Public callback operators, which fill the array with new instruction/data
**	- Public helper methods
**      - align inserts alignment bytes
**      - tok2op returns the opcode corresponding to a specific instruction
**      - fit_imm returns the 16-bit signed immediate version of an integer
**      - ins_is_mem returns wether an instruction accesses memory
**	- Public method to print the internal array 
**	- Private byte array, which holds the output 
**	- Private offset which holds the current offset
*******************************************************************************/
constexpr int OFFSET_OP		= 27;
constexpr int OFFSET_IMM_EN	= 26;
constexpr int OFFSET_RA		= 21;
constexpr int OFFSET_RB		= 16;
constexpr int OFFSET_IMM	= 0;

class Assembler
{
	public:
		Assembler() : offset(0) {};
		
		std::vector<uint8_t> assemble(std::vector<ASTLine> &lines, SymbolTable &symtab);
		Assembler &operator<<(uint8_t data);
		Assembler &operator<<(uint16_t data);
		Assembler &operator<<(uint32_t data);
		uint16_t align(uint16_t &loc,uint16_t alignment);
		uint32_t tok2op(TOK tok);
		uint16_t fit_imm(int32_t val,TOK type);
		bool ins_is_mem(TOK type);
		friend std::ostream &operator<<(std::ostream &stream,Assembler &assembler);
		
	private:
		std::vector<uint8_t> output;
		uint16_t offset;
};
#endif
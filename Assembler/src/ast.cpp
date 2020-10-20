#include <iostream>
#include <string>
#include <memory>
#include <cstdint>
#include "tokens.hpp"
#include "ast.hpp"
#include "symbol_table.hpp"
#include "assembler.hpp"

/*******************************************************************************
** AST class implementations
** Contains
**	- Size functions for all instruction
**	- Calculate functions for all expressions
**	- Assemble functions for all instructions
*******************************************************************************/

// size()-> 16-bit unsigned int 
// Instruction None and Instruction define do not produce output, thus size is 0
// Instruction data has the size of the data it contains. Either 1 or 4
// All normal instructions are a full 4 bytes.
uint16_t ASTInsNone::size()			{ return 0; }
uint16_t ASTInsRegReg::size()		{ return 4; }
uint16_t ASTInsRegImm::size()		{ return 4; }
uint16_t ASTInsRegRegImm::size()	{ return 4; }
uint16_t ASTInsDefine::size()		{ return 0; }
uint16_t ASTInsData::size()			{ return type==TOK::DB?1:4; }

// calculate -> 32-bit signed int
// Constant just returns its value 
// Negate returns the negative of its expression 
// Bad expression should not be called, but for safety returns 0
// Identifier looks up the value of its label and extends the sign
//	- Gives error if not defined
int32_t ASTNumber::calculate(SymbolTable &symtab)		{ return value; }
int32_t ASTUnaryExpr::calculate(SymbolTable &symtab)	{ return -exp->calculate(symtab); }
int32_t ASTBadExpr::calculate(SymbolTable &symtab)		{ return 0; }
int32_t ASTIdentifier::calculate(SymbolTable &symtab)
{
	if(!symtab.contains(id))
	{
		symtab.error++;
		std::cerr<<"Error: label "<<id<<" undefined on line "<<linenumber<<"\n";
		return 0;
	}
	else 
	{
		int32_t val=symtab[id];
		if(val&(1<<15))
			val=0xffff0000|val;
		return val;
	}
}

// assemblee()
// Does not do anything for empty instructions
// Appends the instruction pattern to the output otherwise
void ASTInsNone::assemble(Assembler &assembler, SymbolTable &symtab)	{	}
void ASTInsDefine::assemble(Assembler &assembler, SymbolTable &symtab)	{	}

void ASTInsRegReg::assemble(Assembler &assembler, SymbolTable &symtab)		
{
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(dest.reg<<OFFSET_RA)|(source.reg<<OFFSET_RB));
}

void ASTInsRegImm::assemble(Assembler &assembler, SymbolTable &symtab)		
{ 
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(dest.reg<<OFFSET_RA)|(1<<OFFSET_IMM_EN)|(assembler.fit_imm(source->calculate(symtab),type)<<OFFSET_IMM));
}

void ASTInsRegRegImm::assemble(Assembler &assembler, SymbolTable &symtab)	
{ 
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(left.reg<<OFFSET_RA)|(right.reg<<OFFSET_RB)|(assembler.fit_imm(target->calculate(symtab),type)<<OFFSET_IMM));
}

void ASTInsData::assemble(Assembler &assembler, SymbolTable &symtab)	
{
	if(type==TOK::DB)
	{
		assembler<<(uint8_t)data->calculate(symtab);
	}
	else 
		assembler<<(uint32_t)data->calculate(symtab);
}
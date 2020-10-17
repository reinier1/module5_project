#include <iostream>
#include <string>
#include <memory>
#include <cstdint>
#include "tokens.hpp"
#include "ast.hpp"
#include "symbol_table.hpp"
#include "assembler.hpp"

uint16_t ASTInsNone::size()			{ return 0; }
uint16_t ASTInsRegReg::size()		{ return 4; }
uint16_t ASTInsRegImm::size()		{ return 4; }
uint16_t ASTInsRegRegImm::size()	{ return 4; }

uint16_t ASTNumber::calculate(SymbolTable &symtab)		{ return value; }
uint16_t ASTBadExpr::calculate(SymbolTable &symtab)		{ return 0; }
uint16_t ASTIdentifier::calculate(SymbolTable &symtab)
{
	if(!symtab.contains(id))
	{
		symtab.error++;
		std::cerr<<"Error: label "<<id<<" undefined on line "<<linenumber<<"\n";
		return 0;
	}
	else 
		return symtab[id];
}

void ASTInsNone::assemble(Assembler &assembler, SymbolTable &symtab)	{	}
void ASTInsRegReg::assemble(Assembler &assembler, SymbolTable &symtab)		
{
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(dest.reg<<OFFSET_RA)|(source.reg<<OFFSET_RB));
}
void ASTInsRegImm::assemble(Assembler &assembler, SymbolTable &symtab)		
{ 
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(dest.reg<<OFFSET_RA)|(1<<OFFSET_IMM_EN)|(source->calculate(symtab)<<OFFSET_IMM));
}
void ASTInsRegRegImm::assemble(Assembler &assembler, SymbolTable &symtab)	
{ 
	assembler<<((assembler.tok2op(type)<<OFFSET_OP)|(left.reg<<OFFSET_RA)|(right.reg<<OFFSET_RB)|(target->calculate(symtab)<<OFFSET_IMM));
}
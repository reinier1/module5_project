#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP
#include <vector>
#include <map>
#include <string>
#include "ast.hpp"

/*******************************************************************************
** Symbol table class definition
** Contains
**	- Number of symbol errors
** 	- Public constructor, which creates the actual symbol table from the AST
**	- Public method contain to check wether a label has been definded
**	- Public method to acces the label definitions
**	- Private dictionary to contain all label location pairs
** Seperate align, which aligns an offset to a specific alignment
*******************************************************************************/

uint32_t align(uint16_t &offset,uint16_t alignment);
class SymbolTable
{
	public:
		SymbolTable(std::vector<ASTLine> &lines);
		
		int error;
		
		bool contains(std::string label);
		uint16_t &operator[](std::string label);
		
	private:
		std::map<std::string,uint16_t> dictionary;
};
#endif
#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP
#include <vector>
#include <map>
#include <string>
#include "ast.hpp"
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
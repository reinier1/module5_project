#include <vector>
#include <map>
#include <string>
#include "symbol_table.hpp"
#include "ast.hpp"
SymbolTable::SymbolTable(std::vector<ASTLine> &lines) : error(0)
{
	uint16_t loc=0;
	for(auto &it : lines)
	{
		if(it.labeled)
		{
			if(contains(it.label.str))
			{
				error++;
				std::cerr << "Error: label " << it.label.str << " redefined on line " << it.linenumber << "\n";
			}
			else
			{
				dictionary[it.label.str]=loc;
			}
		}
		loc+=it.instruction->size();
	}
}

bool SymbolTable::contains(std::string label)
{
	return dictionary.count(label)>0;
}

uint16_t &SymbolTable::operator[](std::string label)
{
	return dictionary[label];
}
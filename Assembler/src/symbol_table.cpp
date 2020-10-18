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
		int size=it.instruction->size();
		align(loc,size);
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
		it.instruction->define(*this);
		loc+=size;
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

void ASTInstruction::define(SymbolTable &symtab)	{	}
void ASTInsDefine::define(SymbolTable &symtab)
{
	if(symtab.contains(name))
	{
		symtab.error++;
		std::cerr << "Error: address " << name << " redefined\n";
	}
	else
	{
		symtab[name]=data->calculate(symtab);
	}
}

uint32_t align(uint16_t &offset,uint16_t alignment)
{
	if(alignment==0)
		return offset;
	uint16_t difference=offset%alignment;
	if(difference==0)
		return offset;
	else 
	{
		return offset+=alignment-difference;
	}
}
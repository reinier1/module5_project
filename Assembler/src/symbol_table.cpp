#include <vector>
#include <map>
#include <string>
#include "symbol_table.hpp"
#include "ast.hpp"
/*******************************************************************************
** Symbol table class implementation
** Contains
** 	- Public constructor, which creates the actual symbol table from the AST
**	- Public method contain to check wether a label has been definded
**	- Public method to acces the label definitions
** Definition implementation for AST instruction define
** Align function, which aligns an offset to a specific alignment
*******************************************************************************/

// Constructor(List of lines) -> SymbolTable
// Foreach line in lines
//	- Align current offset
//	- If labeled add label 
//	- If define instruction, define
// 	- Increment offset
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

// contains(string) -> boolean
// return true if dictionary includes labels else return false
bool SymbolTable::contains(std::string label)
{
	return dictionary.count(label)>0;
}

// operator[string] -> 16-bit unsigned int
// Return the dictionary entry
uint16_t &SymbolTable::operator[](std::string label)
{
	return dictionary[label];
}

// Normal instructions do not use define
void ASTInstruction::define(SymbolTable &symtab)	{	}

// define(SymbolTable)
// If symbol already present print error 
// Else insert data for label
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

// align(16-bit unsigned int, 16-bit unsigned int) -> 32-bit unsigned int
// If no alignment is specified return offset
// If the alignment is already correct return offset
// Else return the next valid offset, which is aligned
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
#include <iostream>
#include <vector>
#include "lexer.hpp"

int main()
{
	Lexer lexer(std::cin);
	auto tokens=lexer.lex();
	for(auto it : tokens)
		std::cerr<<it<<" ";
}
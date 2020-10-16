#ifndef LEXER_HPP
#define LEXER_HPP
#include <vector>
#include <iostream>
#include "tokens.hpp"
class Lexer
{
	public:
		Lexer(std::istream &stream) : stream{&stream} , linenumber(0) {};
		std::vector<Token> lex();
		
	private:
		std::istream *stream;
		int linenumber;
		
		int popc();
		inline int peekc() {return stream->peek();};
		Token lex_token();
		Token lex_number();
		Token lex_id();
};
#endif
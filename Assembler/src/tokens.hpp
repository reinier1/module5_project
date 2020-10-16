#ifndef TOKENS_HPP
#define TOKENS_HPP
#include <string>
#include <iostream>
#include <cstdint>

enum class TOK {		
				NUMBER,IDENTIFIER,
				ADD,SUB,MUL,AND,OR,XOR,SLA,SRA,MOVE,
				JP,JALR,JAL,JR,BEQ,BNE,BLT,BLTU,
				LW,LB,SW,SB,
				COLON,COMMA,LBRACKET,RBRACKET, PERCENT,
				EOL,END,NONE,REG
				};
std::ostream &operator<<(std::ostream &stream,const TOK tok);

struct Token
{
	Token(TOK id, int linenumber) : id{id} , linenumber{linenumber} {};
	Token(TOK id, int linenumber, std::string str) : id{id} , linenumber{linenumber} , str{str} {};
	Token(TOK id, int linenumber, uint32_t val) : id{id} , linenumber{linenumber} , value{val} {};
	
	TOK id;
	int linenumber;
	uint32_t value;
	std::string str;
	
	friend std::ostream &operator<<(std::ostream &stream,const Token tok);
};
#endif
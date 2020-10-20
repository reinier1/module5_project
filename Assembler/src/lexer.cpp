#include <fstream>
#include <vector>
#include <cctype>
#include "lexer.hpp"

/*******************************************************************************
** Lexer class implementation
** Contains
**	- Private method the get a new character and advance linenumber
** 	- Public lex method, which returns a list of tokens 
**	- Private methods to lex specific types of tokens
**	- Private map for string to instruction token conversion
*******************************************************************************/

// popc() -> int 
// Gets new character and advances lexing stream
// If the new character is a new line, we increment the line number
// Return new character
int Lexer::popc()
{
	int c=stream->get();
	if(c=='\n')
		linenumber++;
	return c;
}

// lex() -> list of tokens
// While we haven't reached the end of the file
//    Append next token to list
// Append EOF token list 
// Return list
std::vector<Token> Lexer::lex()
{
	std::vector<Token> vec;
	while(peekc()!=EOF)
	{
		vec.push_back(lex_token());
	}
	vec.push_back(Token(TOK::END,linenumber));
	return vec;
}

// lex_token() -> token 
// Remove leading white space
// If end of line of end of file is reached then return token
// If character is digit return lex digit 
// If character is alphabetic return lex identifier
// If character is start of register return (register : number)
// If character is valid punctuation return punctuation
// Else return error
Token Lexer::lex_token()
{
	int c;
	for(c=peekc();(std::isspace(c))&&(c!='\n');c=peekc())
		popc();
	if((c=='\n')||(c==EOF))
	{
		popc();
		return Token(TOK::EOL,linenumber);
	}
	else if(std::isdigit(c))
		return lex_number();
	else if(std::isalpha(c)||c=='_')
		return lex_id();
	else if(std::ispunct(c))
	{
		switch(popc())
		{
			case ',': return Token(TOK::COMMA,linenumber);
			case ':': return Token(TOK::COLON,linenumber);
			case '[': return Token(TOK::LBRACKET,linenumber);
			case ']': return Token(TOK::RBRACKET,linenumber);
			case '-': return Token(TOK::MINUS,linenumber);
			case '%': 
			{
				if(peekc()!='r')
				{
					error++;
					std::cerr<<"Error: Bad register on line "<<linenumber<<"\n";
				}
				else 
				{
					popc();
					uint32_t num=lex_number().value;
					if(num>31)
					{
						error++;
						std::cerr<<"Error: Bad register on line "<<linenumber<<"\n";
					}
					else 
					{
						return Token(TOK::REG,linenumber,num);
					}
				}

			}
			default:
				error++;
				std::cerr<<"Error: Unkown punctuation '"; std::cerr.put(c); std::cerr<<"' on line "<<linenumber<<"\n";
		}
	}
	else
	{
		error++;
		std::cerr<<"Error: Unkown symbol '"<<popc()<<"' on line "<<linenumber<<"\n";
	}
	return Token(TOK::EOL,linenumber);
}

// lex_number() -> token 
// If number is hexadecimal
//   foreach hex digit append it to current value
// Else 
//   Foreach digit append it to current value
// Return (Number : value)
Token Lexer::lex_number()
{
	uint32_t n=0;
	if(peekc()=='0')
	{
		popc();
		if((peekc()=='x')||(peekc()=='X'))
		{
			popc();
			for(int c=peekc();std::isxdigit(c);c=peekc())
			{
				popc();
				if(isdigit(c))
					n=16*n+c-'0';
				else if(islower(c))
					n=16*n+10+c-'a';
				else if(isupper(c))
					n=16*n+10+c-'A';
			}
		}
		else 
		{
			for(int c=peekc();std::isdigit(c);c=peekc())
			{
				popc();
				n=10*n+c-'0';
			}
		}
	}
	else 
	{
		for(int c=peekc();std::isdigit(c);c=peekc())
		{
			popc();
			n=10*n+c-'0';
		}
	}
	return Token(TOK::NUMBER,linenumber,n);
}

// lex_id() -> token 
// Foreach identifier character append character to string
// If identifier is an instruction then return corresponding instruction
// Else return (Identifier : string)
Token Lexer::lex_id()
{
	std::string str;
	for(int c=peekc();std::isalnum(c)||(c=='_');c=peekc())
	{
		popc();
		str.push_back(c);
	}
	if(string2TOK.count(str))
	{
		return Token(string2TOK[str],linenumber);
	}
	else
		return Token(TOK::IDENTIFIER,linenumber,str);
}

// This is a lookup table from instruction string to corresponding token. 
// All instructions in upper and lowercase return their corresponding token type
std::map<std::string,TOK> Lexer::string2TOK
{
	{"ADD",TOK::ADD},
	{"add",TOK::ADD},
	{"SUB",TOK::SUB},
	{"sub",TOK::SUB},
	{"MUL",TOK::MUL},
	{"mul",TOK::MUL},
	{"AND",TOK::AND},
	{"and",TOK::AND},
	{"OR",TOK::OR},
	{"or",TOK::OR},
	{"XOR",TOK::XOR},
	{"xor",TOK::XOR},
	{"SLA",TOK::SLA},
	{"sla",TOK::SLA},
	{"SRA",TOK::SRA},
	{"sra",TOK::SRA},
	{"MOV",TOK::MOVE},
	{"mov",TOK::MOVE},
	{"JP",TOK::JP},
	{"jp",TOK::JP},
	{"JALR",TOK::JALR},
	{"jalr",TOK::JALR},
	{"JAL",TOK::JAL},
	{"jal",TOK::JAL},
	{"JR",TOK::JR},
	{"jr",TOK::JR},
	{"BEQ",TOK::BEQ},
	{"beq",TOK::BEQ},
	{"BNE",TOK::BNE},
	{"bne",TOK::BNE},
	{"BLT",TOK::BLT},
	{"blt",TOK::BLT},
	{"BLTU",TOK::BLTU},
	{"bltu",TOK::BLTU},
	{"LW",TOK::LW},
	{"lw",TOK::LW},
	{"LB",TOK::LB},
	{"lb",TOK::LB},
	{"SW",TOK::SW},
	{"sw",TOK::SW},
	{"SB",TOK::SB},
	{"sb",TOK::SB},
	{"DW",TOK::DW},
	{"dw",TOK::DW},
	{"DB",TOK::DB},
	{"db",TOK::DB},
	{"ADDRESS",TOK::ADDRESS},
	{"address",TOK::ADDRESS},
};
#include <iostream>
#include "tokens.hpp"

std::ostream &operator<<(std::ostream &stream,const TOK tok)
{
	switch(tok)
	{
		case TOK::NONE:			return stream<<"none";
		case TOK::EOL:			return stream<<"\n";
		case TOK::END:			return stream<<"EOF\n";
		case TOK::NUMBER: 		return stream<<"number";
		case TOK::IDENTIFIER: 	return stream<<"identifier";
		case TOK::ADD: 			return stream<<"add";
		case TOK::SUB: 			return stream<<"sub";
		case TOK::MUL: 			return stream<<"mul";
		case TOK::AND: 			return stream<<"and";
		case TOK::OR: 			return stream<<"or";
		case TOK::XOR: 			return stream<<"xor";
		case TOK::SLA: 			return stream<<"sla";
		case TOK::SRA: 			return stream<<"sra";
		case TOK::MOVE:			return stream<<"mov";
		case TOK::JP: 			return stream<<"jp";
		case TOK::JALR: 		return stream<<"jalr";
		case TOK::JAL: 			return stream<<"jal";
		case TOK::JR: 			return stream<<"jr";
		case TOK::BEQ:			return stream<<"beq";
		case TOK::BNE:			return stream<<"bne";
		case TOK::BLT: 			return stream<<"blt";
		case TOK::BLTU: 		return stream<<"bltu";
		case TOK::LW: 			return stream<<"lw";
		case TOK::LB: 			return stream<<"lb";
		case TOK::SW: 			return stream<<"sw";
		case TOK::SB: 			return stream<<"sb";
		case TOK::COLON:		return stream<<":";
		case TOK::COMMA:		return stream<<",";
		case TOK::PERCENT:		return stream<<"%";
		case TOK::LBRACKET:		return stream<<"[";
		case TOK::RBRACKET:		return stream<<"]";
		case TOK::REG:			return stream<<"reg";
		default:				return stream<<"bad token";
	}
}

std::ostream &operator<<(std::ostream &stream,const Token tok)
{
	switch(tok.id)
	{
		case TOK::NUMBER:		return stream<<"(number:"<<tok.value<<")";
		case TOK::IDENTIFIER:	return stream<<"(identifier:"<<tok.str<<")";
		case TOK::REG:			return stream<<"%r"<<tok.value;
		case TOK::EOL:			return stream<<"\n";
		default:				return stream<<tok.id;	
	}
	
}
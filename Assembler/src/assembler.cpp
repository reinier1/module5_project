#include <cstdint>
#include <vector>
#include <iostream>
#include <iomanip>
#include "tokens.hpp"
#include "ast.hpp"
#include "symbol_table.hpp"
#include "assembler.hpp"

std::vector<uint8_t> Assembler::assemble(std::vector<ASTLine> &lines,SymbolTable &symtab)
{
	for(auto &it : lines)
	{
		it.instruction->assemble(*this,symtab);
	}
	return output;
}

Assembler &Assembler::operator<<(uint8_t data)
{
	output.push_back(data);
	offset+=1;
	return *this;
}

Assembler &Assembler::operator<<(uint16_t data)
{
	align(offset,2);
	output.push_back((data>>0)&0xff);
	output.push_back((data>>8)&0xff);
	offset+=2;
	return *this;
}

Assembler &Assembler::operator<<(uint32_t data)
{
	align(offset,4);
	output.push_back((data>>0)&0xff);
	output.push_back((data>>8)&0xff);
	output.push_back((data>>16)&0xff);
	output.push_back((data>>24)&0xff);
	offset+=4;
	return *this;
}

uint32_t Assembler::align(uint16_t &offset,uint16_t alignment)
{
	uint16_t difference=offset%alignment;
	if(difference==0)
		return offset;
	else 
	{
		return offset+=alignment-difference;
	}
}

uint32_t Assembler::tok2op(TOK tok)
{
	switch(tok)
	{
		case TOK::ADD: 	return 0b00000;
		case TOK::SUB: 	return 0b00001;
		case TOK::MUL: 	return 0b00010;
		case TOK::AND: 	return 0b00011;
		case TOK::OR: 	return 0b00100;
		case TOK::XOR: 	return 0b00101;
		case TOK::SLA: 	return 0b00110;
		case TOK::SRA: 	return 0b00111;
		case TOK::BEQ:	return 0b01000;
		case TOK::BNE:	return 0b01001;
		case TOK::BLT: 	return 0b01010;
		case TOK::BLTU:	return 0b01011;
		case TOK::LW: 	return 0b10000;
		case TOK::LB: 	return 0b10001;
		case TOK::SW:	return 0b10100;
		case TOK::SB:	return 0b10101;
		case TOK::MOVE:	return 0b11000;
		case TOK::JP: 	return 0b11100;
		default:
			std::cerr<<"Internal Error: Bad token\n";
			return tok2op(TOK::ADD);
	}
}

std::ostream &operator<<(std::ostream &stream,Assembler &assembler)
{
	uint16_t offset=0;
	auto flags=stream.flags();
	auto fill=stream.fill();
	auto width=stream.width();
	stream<<std::hex<<std::setfill('0');
	for(auto it : assembler.output)
	{
		if(offset%4==0)
			stream<<"\n"<<std::setw(4)<<offset<<": "<<std::setw(2);
		stream<<std::setw(2)<<(unsigned int)it<<" ";
		offset+=1;
	}
	stream<<"\n";
	stream.flags(flags);
	stream.fill(fill);
	stream.width(width);
	return stream;
}
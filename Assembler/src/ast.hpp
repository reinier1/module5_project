#ifndef AST_HPP
#define AST_HPP
#include <string>
#include <memory>
#include <cstdint>
#include "tokens.hpp"
class Assembler;
class SymbolTable;
class AST;
class ASTLine;
class ASTLabel;
class ASTInstruction;

class AST
{
	public:
		AST(int linenumber) : linenumber{linenumber} {};
		
		int linenumber;
};

class ASTLabel : public AST 
{
	public:
		ASTLabel(int linenumber,std::string str) : AST(linenumber) , str{str} {};
		
		std::string str;
};

class ASTInstruction : public AST
{
	public:
		ASTInstruction(int linenumber, TOK type) : AST(linenumber) , type{type} {};
		
		TOK type;
		
		virtual uint16_t size()=0;
		virtual void assemble(Assembler &assembler,SymbolTable &symtab)=0;
};

class ASTExpression : public AST
{
	public:
		ASTExpression(int linenumber) : AST(linenumber) {};
		
		virtual uint16_t calculate(SymbolTable &symtab)=0;
};

class ASTLine : public AST 
{
	public:
		ASTLine(int linenumber,std::unique_ptr<ASTInstruction> instruction) : 
				AST(linenumber) ,  labeled(false) , label(ASTLabel(linenumber,"")) , instruction{std::move(instruction)} {};
		ASTLine(int linenumber,std::unique_ptr<ASTInstruction> instruction, ASTLabel label) : 
				AST(linenumber) , labeled(true) , label{label} , instruction(std::move(instruction)) {};
		
		bool labeled;
		ASTLabel label;
		std::unique_ptr<ASTInstruction> instruction;
};

class ASTNumber : public ASTExpression
{
	public:
		ASTNumber(int linenumber,uint16_t value) : ASTExpression(linenumber) , value{value} {};
		uint16_t value;
		
		uint16_t calculate(SymbolTable &symtab) override;
};

class ASTIdentifier : public ASTExpression
{
	public:
		ASTIdentifier(int linenumber,std::string id) : ASTExpression(linenumber) , id{id} {};
		std::string id;
		
		uint16_t calculate(SymbolTable &symtab) override;
};

class ASTBadExpr : public ASTExpression
{
	public:
		ASTBadExpr(int linenumber) : ASTExpression(linenumber) {};
		
		uint16_t calculate(SymbolTable &symtab) override;
};

class ASTReg : public AST
{
	public:
		ASTReg(int linenumber,int reg) : AST(linenumber) , reg{reg} {};
		int reg;
};

class ASTInsNone : public ASTInstruction
{
	public:
		ASTInsNone(int linenumber) : ASTInstruction(linenumber,TOK::NONE) {};
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

class ASTInsRegReg : public ASTInstruction
{
	public:
		ASTInsRegReg(int linenumber, TOK tok, ASTReg dest, ASTReg source) : ASTInstruction(linenumber,tok) , dest{dest} , source{source} {};
		
		ASTReg dest;
		ASTReg source;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

class ASTInsRegImm : public ASTInstruction
{
	public:
		ASTInsRegImm(int linenumber, TOK tok, ASTReg dest, std::unique_ptr<ASTExpression> source) : 
					ASTInstruction(linenumber,tok) , dest{dest} , source{std::move(source)} {};
					
		ASTReg dest;
		std::unique_ptr<ASTExpression> source;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

class ASTInsRegRegImm : public ASTInstruction
{
	public:
		ASTInsRegRegImm(int linenumber, TOK tok, ASTReg left, ASTReg right, std::unique_ptr<ASTExpression> target) :
					ASTInstruction(linenumber,tok), left{left} , right{right} , target{std::move(target)} {};
		
		ASTReg left;
		ASTReg right;
		std::unique_ptr<ASTExpression> target;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};
#endif
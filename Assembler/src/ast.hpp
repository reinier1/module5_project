#ifndef AST_HPP
#define AST_HPP
#include <string>
#include <memory>
#include <cstdint>
#include "tokens.hpp"
/*******************************************************************************
** AST class definitions
** The base AST class contains 
**	- A linenumber
** The derived class are:
**  - A label class to store a label name 
**	- A line class which contains an instruction and a label
**	- An instruction class from which specific instruction are derived:
**	- Contains:
**	   - A type 
**	   - Method size, which returns size 
**	   - Method assemble, which will insert an instruction into the byte stream
**	   - Method defined for instructions that define labels
**	- An expression class from which specific expression are derived
**	   - Can calculate its value
** 	- Register class which contains a register number
*******************************************************************************/
class Assembler;
class SymbolTable;
class AST;
class ASTLine;
class ASTLabel;
class ASTInstruction;

// AST base class
class AST
{
	public:
		AST(int linenumber) : linenumber{linenumber} {};
		virtual ~AST()=default;
		
		int linenumber;
};

// AST label class
class ASTLabel : public AST 
{
	public:
		ASTLabel(int linenumber,std::string str) : AST(linenumber) , str{str} {};
		virtual ~ASTLabel() override=default;
		
		std::string str;
};

// Ast instruction base class.
class ASTInstruction : public AST
{
	public:
		ASTInstruction(int linenumber, TOK type) : AST(linenumber) , type{type} {};
		virtual ~ASTInstruction() override=default;
		
		TOK type;
		
		virtual uint16_t size()=0;
		virtual void assemble(Assembler &assembler,SymbolTable &symtab)=0;
		virtual void define(SymbolTable &symtab);
};

// Ast expression base type
class ASTExpression : public AST
{
	public:
		ASTExpression(int linenumber) : AST(linenumber) {};
		virtual ~ASTExpression() override=default;
		
		virtual int32_t calculate(SymbolTable &symtab)=0;
};

// AST line class
// Contains:
//	- Boolean wether this instruction is labeled
//	- A label if there was one
//	- An instruction
class ASTLine : public AST 
{
	public:
		ASTLine() : AST(0) ,  labeled(false) , label(ASTLabel(0,"")) , instruction{nullptr} {};
		ASTLine(int linenumber,std::unique_ptr<ASTInstruction> instruction) : 
				AST(linenumber) ,  labeled(false) , label(ASTLabel(linenumber,"")) , instruction{std::move(instruction)} {};
		ASTLine(int linenumber,std::unique_ptr<ASTInstruction> instruction, ASTLabel label) : 
				AST(linenumber) , labeled(true) , label{label} , instruction(std::move(instruction)) {};
		
		bool labeled;
		ASTLabel label;
		std::unique_ptr<ASTInstruction> instruction;
};

// AST expression number. Corresponds to a constant number in the source code
class ASTNumber : public ASTExpression
{
	public:
		ASTNumber(int linenumber,uint32_t value) : ASTExpression(linenumber) , value{value} {};
		virtual ~ASTNumber() override=default;
		
		uint32_t value;
		
		int32_t calculate(SymbolTable &symtab) override;
};

// AST expression identifier. Corresponds to a label in an expression
class ASTIdentifier : public ASTExpression
{
	public:
		ASTIdentifier(int linenumber,std::string id) : ASTExpression(linenumber) , id{id} {};
		virtual ~ASTIdentifier() override=default;
		
		std::string id;
		
		int32_t calculate(SymbolTable &symtab) override;
};

// AST unary expression. Corresponds to an expression with only one operand
// In this case it will always negate the operand it contains
class ASTUnaryExpr : public ASTExpression
{
	public:
		ASTUnaryExpr(int linenumber,TOK type,std::unique_ptr<ASTExpression> exp) : ASTExpression(linenumber) , type{type} , exp{std::move(exp)} {};
		virtual ~ASTUnaryExpr() override=default;
		
		TOK type;
		std::unique_ptr<ASTExpression> exp;
		
		int32_t calculate(SymbolTable &symtab) override;
};

// AST Bad expression. Improves errorhandling by still providing a working class
class ASTBadExpr : public ASTExpression
{
	public:
		ASTBadExpr(int linenumber) : ASTExpression(linenumber) {};
		virtual ~ASTBadExpr() override=default;
		
		int32_t calculate(SymbolTable &symtab) override;
};

// AST register. Contains only the corresponding register number. -1 if bad
class ASTReg : public AST
{
	public:
		ASTReg(int linenumber,int reg) : AST(linenumber) , reg{reg} {};
		virtual ~ASTReg() override=default;
		
		int reg;
};

// AST none instruction. For bad instructions or empty lines
class ASTInsNone : public ASTInstruction
{
	public:
		ASTInsNone(int linenumber) : ASTInstruction(linenumber,TOK::NONE) {};
		virtual ~ASTInsNone() override=default;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

// AST data instruction. Used for db and dw to store data in code
// Contains only an expression for the data
class ASTInsData : public ASTInstruction
{
	public:
		ASTInsData(int linenumber, TOK tok, std::unique_ptr<ASTExpression> data) : 
					ASTInstruction(linenumber,tok) , data{std::move(data)} {};
		virtual ~ASTInsData() override=default;
					
		std::unique_ptr<ASTExpression> data;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

// AST define instruction. Used to define IO addresses
// Contains Label to define and corresponding value
class ASTInsDefine : public ASTInstruction
{
	public:
		ASTInsDefine(int linenumber, TOK tok, std::string name, std::unique_ptr<ASTExpression> data) : 
					ASTInstruction(linenumber,tok) , name{name} , data{std::move(data)} {};
		virtual ~ASTInsDefine() override=default;
					
		std::string name;
		std::unique_ptr<ASTExpression> data;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
		void define(SymbolTable &symtab)override;
};

// AST instruction, with two registers.
class ASTInsRegReg : public ASTInstruction
{
	public:
		ASTInsRegReg(int linenumber, TOK tok, ASTReg dest, ASTReg source) : ASTInstruction(linenumber,tok) , dest{dest} , source{source} {};
		virtual ~ASTInsRegReg() override=default;
		
		ASTReg dest;
		ASTReg source;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

// AST instruction, with a register and an immediate, which should fit into 16-bits.
class ASTInsRegImm : public ASTInstruction
{
	public:
		ASTInsRegImm(int linenumber, TOK tok, ASTReg dest, std::unique_ptr<ASTExpression> source) : 
					ASTInstruction(linenumber,tok) , dest{dest} , source{std::move(source)} {};
		virtual ~ASTInsRegImm() override=default;
					
		ASTReg dest;
		std::unique_ptr<ASTExpression> source;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};

// AST instruction, with two registers and an immediate. This is for compare-and-branch instructions.
class ASTInsRegRegImm : public ASTInstruction
{
	public:
		ASTInsRegRegImm(int linenumber, TOK tok, ASTReg left, ASTReg right, std::unique_ptr<ASTExpression> target) :
					ASTInstruction(linenumber,tok), left{left} , right{right} , target{std::move(target)} {};
		virtual ~ASTInsRegRegImm() override=default;
		
		ASTReg left;
		ASTReg right;
		std::unique_ptr<ASTExpression> target;
		
		uint16_t size() override;
		void assemble(Assembler &assembler, SymbolTable &symtab) override;
};
#endif
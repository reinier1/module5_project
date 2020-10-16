IDIR =./src
CXXFLAGS=-I$(IDIR) -Wall -Werror -Wno-unused-function -Wno-unused-variable

ODIR=./obj
DIR =./src

_OBJ = tokens.o lexer.o main.o 
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

vpath %.hpp $(IDIR)
vpath %.cpp $(DIR)

all: mod5asm

$(ODIR)/tokens.o: tokens.cpp tokens.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/lexer.o: lexer.cpp lexer.hpp tokens.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/main.o: main.cpp lexer.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 

mod5asm: $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -f $(OBJ)
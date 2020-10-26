LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.math_real.ALL;
USE ieee.numeric_std.ALL; 
ENTITY alu IS
  
  PORT ( clk                     : IN std_logic;
         reset                   : IN std_logic;
         alu_opcode              : IN std_logic_vector(3 DOWNTO 0);  --there are on this moment 3 bits necessary but the fourth when is for extra comments
	     register_a			     : IN signed(31 DOWNTO 0);
		 register_b			     : IN signed(31 DOWNTO 0);
	     register_out			 : OUT signed(31 DOWNTO 0);
		 flags					 : OUT std_logic_vector(3 downto 0) -- on this moment 4 flags are enough but for futher expansion 4 bits are reserved
	      ); 
END alu;
ARCHITECTURE bhv OF alu IS
	
begin 
	process(clk, reset) 
	begin
		if reset = '0' then
			register_out <= ( others => '0');
			flags <= (others => '0'); -- no flags set
			
		elsif rising_edge(clk) then
			CASE alu_opcode IS          
				WHEN "0000" => register_out <= (register_a + register_b);
				WHEN "0001" => register_out <= (register_a - register_b);
				WHEN "0010" => register_out <= (resize((register_a * register_b), 32));
				WHEN "0011" => register_out <= (register_a and register_b);
				WHEN "0100" => register_out <= (register_a or register_b);
				WHEN "0101" => register_out <= (register_a xor register_b);
				WHEN "0110" => register_out <=  (shift_left( (register_a), to_integer(register_b)));-- shift_left works a bit strange
				WHEN "0111" => register_out <= shift_right(register_a, to_integer(register_b));
				WHEN OTHERS => register_out <= (others => '0');	
			END CASE;
			--with the following flags setting the control only has to check 1 bit at the time
			if (register_a = register_b) then --for branch equal
				flags <= "1001";
			
			else
				flags(0) <= '0';
				if (unsigned(register_a) < unsigned(register_b)) then --for branch unsigned less
					flags(1) <= '1';
				else 
					flags(1) <= '0';
				end if;
				if (register_a < register_b) then --for branch signed less then
					flags(2) <= '1';
				else 
					flags(2) <= '0';
				end if;
			end if; 
		end if ;
	end process;
	
END bhv;
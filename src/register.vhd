library ieee; 
use ieee.std_logic_1164.all; 
  
entity Reg is
	generic (width: integer:=16);
	port ( D: in std_logic_vector((width-1) downto 0);
			 Q: out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);

end Reg; 

architecture struct of Reg is
begin

	process(clk, clr)
		begin
			if clr = '0' then
				Q <= (others =>'0');
			elsif rising_edge(clk) then
				if en = '1' then
					Q <= D;
				end if;
			end if;
	end process;
					
end struct;

library ieee; 
use ieee.std_logic_1164.all; 

entity FF is
	port ( D: in std_logic;
			 Q: out std_logic;
			 clr, clk, en: in std_logic);

end FF; 

architecture struct of FF is
begin

	process(clk, clr)
		begin
			if clr = '0' then
				Q <= '0';
			elsif rising_edge(clk) then
				if en = '1' then
					Q <= D;
				end if;
			end if;
	end process;
					
end struct;
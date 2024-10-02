library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;   

entity RAM is
	port(	data_in	: in std_logic_vector(15 downto 0);
			addr		: in std_logic_vector(15 downto 0);
			w_en		: in std_logic := '0';
			clk		: in std_logic;
			data_out	: out std_logic_vector(15 downto 0)
		 );
end entity;

architecture struct of RAM is

type mem_type is array (0 to 255) of std_logic_vector(15 downto 0);
signal mem: mem_type:= (/*0 => X"0001",
								1 => X"0002",
								2 => X"0003",
								3 => X"0004",
								4 => X"0005",*/
								others => (others => '1'));

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(w_en = '1') then
				mem(conv_integer(addr(3 downto 0))) <= data_in;
			end if;
			
		end if;
	end process;
	
	data_out <= mem(conv_integer(addr(3 downto 0)));
	
end struct;

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.bus_multiplexer_pkg.all;

-------------------------------ALU STARTS-----------------------------------  

entity ALU is
	port ( alu_a: 				in std_logic_vector(15 downto 0);
			 alu_b: 				in std_logic_vector(15 downto 0);
			 alu_sel:			in std_logic_vector(1 downto 0);
			 alu_out:			out std_logic_vector(15 downto 0);
			 C, Z:				out std_logic);
end ALU; 

architecture struct of ALU is

component adder is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0);
			 c_out: 	out std_logic);
end component;

component sub is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0));
end component;

component not_and is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0));
end component; 

component FF is
	port ( D: 		in std_logic;
			 Q: 		out std_logic;
			 clr,clk:in std_logic;
			 en: 		in std_logic);
end component;

component MUX is
        generic (bus_width : 	positive := 16;
                sel_width : 	positive := 3);
        port (  i : 		in bus_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
                sel : 	in std_logic_vector(sel_width - 1 downto 0);
                o : 		out std_logic_vector(bus_width - 1 downto 0));
end component;

signal temp:										std_logic_vector(15 downto 0);
signal add_result,sub_result,nand_result: std_logic_vector(15 downto 0);
signal c_flag_in:		 							std_logic;


begin
	
	add : 	adder port map(alu_a, alu_b, add_result, c_flag_in);
	subb: 	sub port map(alu_a, alu_b, sub_result);
	n: 		not_and port map(alu_a, alu_b, nand_result);
	
	MUX_result:	MUX 	generic map(16,2)
							port map(i(0) => add_result, 
										i(1) => nand_result, 
										i(2) => sub_result, 
										i(3) => (others => 'X'), 
										sel  => alu_sel, 
										o    =>temp);
	
	alu_out 		<= temp;
	C <= c_flag_in;
	Z <= '1' when temp = "0000000000000000" else 
		  '0';
	
end struct;

---------------------------------------ADDER STARTS------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0);
			 c_out: 	out std_logic);
end entity;

architecture struct of adder is

signal temp: std_logic_vector(16 downto 0);

begin

	temp 	<= ('0' & A) + ('0' & B) ;
	Y 		<= temp(15 downto 0);
	c_out <= temp(16);
	
end struct;

----------------------------------SUB STARTS-------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sub is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0));
end entity;

architecture struct of sub is

signal temp: std_logic_vector(15 downto 0);

begin

	temp 	<= A - B;
	Y 		<= temp(15 downto 0);
	
end struct;

----------------------------------NAND STARTS-----------------------------------

library ieee; 
use ieee.std_logic_1164.all;

entity not_and is
	port ( A: 		in std_logic_vector(15 downto 0);
			 B: 		in std_logic_vector(15 downto 0);
			 Y: 		out std_logic_vector(15 downto 0));
end entity; 

architecture struct of not_and is
begin
	Y <= A nand B;
end struct;



library ieee; 
use ieee.std_logic_1164.all; 

entity Testbench is
end entity;

architecture Behave of Testbench is

component processor is
	port ( rst, clk: 			in std_logic;
			 R7_out:				out std_logic_vector(15 downto 0);
			 R0_out, R1_out:	out std_logic_vector(15 downto 0);
			 C_out,Z_out:		out std_logic);
end component;


constant CLK_PERIOD: time:= 20ns;
signal rst, clk	: std_logic;
signal R7,R0, R1	: std_logic_vector(15 downto 0);
signal C,Z			: std_logic;

begin

DUT: processor port map( rst, clk,
								 R7, R0, R1,
								 C,Z);

	clk_generation : process
	begin
		clk <= '1';
		wait for CLK_PERIOD / 2;
		clk <= '0';
		wait for CLK_PERIOD / 2;
	end process clk_generation;


	simulation: process
	begin

		rst	<= '0';
		wait for 1ns;
		
		rst	<= '1';
		wait for 1000000000ns;
		wait for 1000000000ns;
		wait for 1000000000ns;
	end process simulation;


end behave;


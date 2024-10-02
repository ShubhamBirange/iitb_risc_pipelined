library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bus_multiplexer_pkg.all;

entity reg_file is
	port ( A1, A2, A3: 	in std_logic_vector(2 downto 0);
			 d3: 				in std_logic_vector(15 downto 0);
			 clr, clk: 		in std_logic;
			 w_en: 			in std_logic;
			 d1, d2: 		out std_logic_vector(15 downto 0);
			 r7_en:			in std_logic;
			 r7_in:			in std_logic_vector(15 downto 0);
			 r7_out:		   out std_logic_vector(15 downto 0);
			 r0_out:		   out std_logic_vector(15 downto 0);
			 r1_out:		   out std_logic_vector(15 downto 0);
			 r2_out:		   out std_logic_vector(15 downto 0);
			 r3_out:		   out std_logic_vector(15 downto 0));
end reg_file;

architecture struct of reg_file is

component Reg is
	port ( D: 				in std_logic_vector(15 downto 0);
			 Q: 				out std_logic_vector(15 downto 0);
			 clr, clk, en: in std_logic);

end component; 

component MUX is
        generic (bus_width : positive := 16;
                sel_width : positive := 3);
        port (  i : in bus_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
                sel : in std_logic_vector(sel_width - 1 downto 0);
                o : out std_logic_vector(bus_width - 1 downto 0));
end component;

component write_en is
	port ( A: 		in std_logic_vector(2 downto 0);
			 w_en: 	in std_logic;
			 r7_en: 	in std_logic;
			 reg_en: out std_logic_vector(7 downto 0));
end component;


signal reg_en: std_logic_vector(7 downto 0);
signal reg_in,reg_out: bus_array(7 downto 0)(15 downto 0);

begin
	
	R: for i in 0 to 7 generate
      RX : Reg port map(reg_in(i), reg_out(i), clr, clk, reg_en(i));
   end generate R;
	
	reg_in(6 downto 0) <= (others => d3);
	reg_in(7)	<= r7_in when r7_en = '1'
						else d3;
	--r_out <= reg_out;
	MUX_T1: MUX port map(reg_out, A1, d1);
	MUX_T2: MUX port map(reg_out, A2, d2);
	
	w: write_en port map(A3, w_en, r7_en, reg_en); 
	r7_out <= reg_out(7);

	r0_out <= reg_out(0);
	r1_out <= reg_out(1);
	r2_out <= reg_out(2);
	r3_out <= reg_out(3);
	
end struct;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_en is
	port ( A: 		in std_logic_vector(2 downto 0);
			 w_en: 	in std_logic;
			 r7_en: 	in std_logic;
			 reg_en: out std_logic_vector(7 downto 0));
end write_en;

architecture struct of write_en is
signal y: std_logic_vector(7 downto 0);

begin
with A select
y <=	"00000001" when "000",
		"00000010" when "001",
		"00000100" when "010",
		"00001000" when "011",
		"00010000" when "100",
		"00100000" when "101",
		"01000000" when "110",
		"10000000" when others;
reg_en(6 downto 0) <= y(6 downto 0) when w_en = '1' else
								(others => '0');
reg_en(7) <= r7_en;

end struct;
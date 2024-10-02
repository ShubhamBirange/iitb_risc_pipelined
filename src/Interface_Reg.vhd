library ieee; 
use ieee.std_logic_1164.all;

entity IF_Reg is
	port (rst, clk, en: in std_logic;
			pc_in			: in std_logic_vector(15 downto 0);
			ir_in			: in std_logic_vector(15 downto 0);
			pc_out		: out std_logic_vector(15 downto 0);
			ir_out		: out std_logic_vector(15 downto 0));
end entity;

architecture struct of IF_Reg is

component Reg is
	port ( D: 				in std_logic_vector(15 downto 0);
			 Q: 				out std_logic_vector(15 downto 0);
			 clr, clk, en: in std_logic);
end component; 

begin

	PC: Reg port map(pc_in, pc_out, rst, clk, en);
	IR: Reg port map(ir_in, ir_out, rst, clk, en);	

end struct;

library ieee; 
use ieee.std_logic_1164.all;

entity ID_Reg is
	port (rst, clk, en: in std_logic;
			pc_in			: in std_logic_vector(15 downto 0);
			ir_in			: in std_logic_vector(15 downto 0);
			pc_out		: out std_logic_vector(15 downto 0);
			ir_out		: out std_logic_vector(15 downto 0);
			
			d1_df_in		: in std_logic_vector(2 downto 0);
			d2_df_in		: in std_logic_vector(2 downto 0);
			d1_df_sel	: out std_logic_vector(2 downto 0);
			d2_df_sel	: out std_logic_vector(2 downto 0);
			
			ID_in			: in std_logic_vector(27 downto 0);
			ID_out		: out std_logic_vector(27 downto 0));
end entity;

architecture struct of ID_Reg is

component Reg is
	generic (width: integer:=16);
	port ( D: 				in std_logic_vector((width-1) downto 0);
			 Q: 				out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

begin

	PC: Reg port map(pc_in, pc_out, rst, clk, en);
	IR: Reg port map(ir_in, ir_out, rst, clk, en);	

	D1_DF: Reg 	generic map(3)
					port map(d1_df_in, d1_df_sel, rst, clk, en);
	D2_DF: Reg 	generic map(3)
					port map(d2_df_in, d2_df_sel, rst, clk, en);		
					
	ID_R: Reg 	generic map(28)
					port map(ID_in, ID_out, rst, clk, en);
end struct;

library ieee; 
use ieee.std_logic_1164.all;

entity OR_Reg is
	port (rst, clk, en: 	in std_logic;
			pc_in			: in std_logic_vector(15 downto 0);
			ir_in			: in std_logic_vector(15 downto 0);
			pc_out		: out std_logic_vector(15 downto 0);
			ir_out		: out std_logic_vector(15 downto 0);
			
			rf_d1_in		: in std_logic_vector(15 downto 0);
			rf_d2_in		: in std_logic_vector(15 downto 0);
			
			rf_d1_out	: out std_logic_vector(15 downto 0);
			rf_d2_out	: out std_logic_vector(15 downto 0);
			
			OR_in			: in std_logic_vector(20 downto 0);
			OR_out		: out std_logic_vector(20 downto 0));
end entity;

architecture struct of OR_Reg is

component Reg is
	generic (width: integer:=16);
	port ( D: 				in std_logic_vector((width-1) downto 0);
			 Q: 				out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

begin

	PC: Reg port map(pc_in, pc_out, rst, clk, en);
	IR: Reg port map(ir_in, ir_out, rst, clk, en);	
	
	rf_d1: Reg port map(rf_d1_in, rf_d1_out, rst, clk, en);
	rf_d2: Reg port map(rf_d2_in, rf_d2_out, rst, clk, en);
	
	OR_R: Reg 	generic map(21)
					port map(OR_in, OR_out, rst, clk, en);
end struct;

library ieee; 
use ieee.std_logic_1164.all;

entity EX_Reg is
	port (rst, clk: 	in std_logic;
			pc_in	: 		in std_logic_vector(15 downto 0);
			ir_in	: 		in std_logic_vector(15 downto 0);
			pc_out: 		out std_logic_vector(15 downto 0);
			ir_out: 		out std_logic_vector(15 downto 0);
			
			rf_d2_in: 	in std_logic_vector(15 downto 0);
			rf_d2_out: 	out std_logic_vector(15 downto 0);
			
			alu_in: 		in std_logic_vector(15 downto 0);
			alu_out: 	out std_logic_vector(15 downto 0);
			
			EX_in: 		in std_logic_vector(13 downto 0);
			EX_out: 		out std_logic_vector(13 downto 0));
end entity;

architecture struct of EX_Reg is

component Reg is
	generic (width: integer:=16);
	port ( D: 				in std_logic_vector((width-1) downto 0);
			 Q: 				out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

begin

	PC: Reg port map(pc_in, pc_out, rst, clk, '1');
	IR: Reg port map(ir_in, ir_out, rst, clk, '1');	
	
	rf_d2: Reg port map(rf_d2_in, rf_d2_out, rst, clk, '1');
	
	alu: Reg port map(alu_in, alu_out, rst, clk, '1');
	
	EX_R: Reg 	generic map(14)
					port map(EX_in, EX_out, rst, clk, '1');
end struct;

library ieee; 
use ieee.std_logic_1164.all;

entity MEM_Reg is
	port (rst, clk: 	in std_logic;

			alu_in: 		in std_logic_vector(15 downto 0);
			alu_out: 	out std_logic_vector(15 downto 0);
			
			RAM_in: 		in std_logic_vector(15 downto 0);
			RAM_out: 	out std_logic_vector(15 downto 0);
			
			MEM_in: 		in std_logic_vector(10 downto 0);
			MEM_out: 	out std_logic_vector(10 downto 0));
end entity;

architecture struct of MEM_Reg is

component Reg is
	generic (width: integer:=16);
	port ( D: 				in std_logic_vector((width-1) downto 0);
			 Q: 				out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

begin

	alu: Reg port map(alu_in, alu_out, rst, clk, '1');
	
	RAM: Reg port map(RAM_in, RAM_out, rst, clk, '1');

	MEM_R: Reg 	generic map(11)
					port map(MEM_in, MEM_out, rst, clk, '1');
end struct;

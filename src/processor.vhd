library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use work.bus_multiplexer_pkg.all;

entity processor is
	port ( rst, clk: 			in std_logic;
			 R7_out:				out std_logic_vector(15 downto 0);
			 R0_out, R1_out:	out std_logic_vector(15 downto 0);
			 C_out,Z_out:		out std_logic);
end entity;

architecture struct of processor is

component ROM is
	port(	addr		: in std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0));
end component;

component RAM is
	port(	data_in	: in std_logic_vector(15 downto 0);
			addr		: in std_logic_vector(15 downto 0);
			w_en		: in std_logic := '0';
			clk		: in std_logic;
			data_out	: out std_logic_vector(15 downto 0));
end component;

component Reg is
	port ( D: 				in std_logic_vector(15 downto 0);
			 Q: 				out std_logic_vector(15 downto 0);
			 clr, clk, en: in std_logic);

end component; 

component reg_file is
	port ( A1, A2, A3: 	in std_logic_vector(2 downto 0);
			 d3: 				in std_logic_vector(15 downto 0);
			 clr, clk: 		in std_logic;
			 w_en: 			in std_logic;
			 d1, d2: 		out std_logic_vector(15 downto 0);
			 r7_en:			in std_logic;
			 r7_in:			in std_logic_vector(15 downto 0);
			 r7_out:		   out std_logic_vector(15 downto 0);
			 r0_out:		   out std_logic_vector(15 downto 0);
			 r1_out:		   out std_logic_vector(15 downto 0));
end component;

component ALU is
	port ( alu_a: 				in std_logic_vector(15 downto 0);
			 alu_b: 				in std_logic_vector(15 downto 0);
			 alu_sel:			in std_logic_vector(1 downto 0);
			 alu_out:			out std_logic_vector(15 downto 0);
			 C, Z:				out std_logic);
end component; 

component Flags is
	port ( c_flag_in, z_flag_in  	: in std_logic;
			 c_flag_out, z_flag_out	: out std_logic;
			 rst, clk				  	: in std_logic;
			 c_W_en, z_w_en			: in std_logic;
			 or_ir_out					: in std_logic_vector(15 downto 0);
			 ex_ir_out					: in std_logic_vector(15 downto 0);
			 ram_out						: in std_logic_vector(15 downto 0);
			 w_en							: out std_logic);
end component; 

component FF is
	port ( D: 		in std_logic;
			 Q: 		out std_logic;
			 clr,clk:in std_logic;
			 en: 		in std_logic);
end component;

component SE is
	generic (in_width: 	integer:=6;
				out_width: 	integer:=16);
	port (i: in std_logic_vector((in_width - 1) downto 0);
			o: out std_logic_vector((out_width - 1) downto 0));
end component;

component MUX is
        generic (bus_width : 	positive := 16;
                sel_width : 	positive := 3);
        port (  i : 		in bus_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
                sel :	in std_logic_vector(sel_width - 1 downto 0);
                o : 		out std_logic_vector(bus_width - 1 downto 0));
end component;

component adder_mux is
	port ( JLR:				in std_logic_vector(1 downto 0);
			 BEQ:				in std_logic_vector(1 downto 0);
			 JAL:				in std_logic_vector(1 downto 0);
			 adder_sel_2:	out std_logic;
			 adder_sel:		out std_logic_vector(1 downto 0));
end component; 

component decoder is
	port (rst,clk:		in std_logic;
			ir_in	: 		in std_logic_vector(15 downto 0);
	      C,Z:			in std_logic;
			
			id_ir_out:  in std_logic_vector(15 downto 0);
			id_rf_w:		in std_logic;
			id_rf_a3:	in std_logic_vector(2 downto 0);
			
			or_ir_out:  in std_logic_vector(15 downto 0);
			or_rf_w:		in std_logic;
			or_rf_a3:	in std_logic_vector(2 downto 0);
			
			ex_ir_out:  in std_logic_vector(15 downto 0);
			ex_rf_w:		in std_logic;
			ex_rf_a3:	in std_logic_vector(2 downto 0);
			
			mem_rf_w:	in std_logic;
			mem_rf_a3:	in std_logic_vector(2 downto 0);
			
			id_branch:	in std_logic_vector(1 downto 0);
			or_branch:	in std_logic_vector(1 downto 0);
			ex_branch:	in std_logic_vector(1 downto 0);
			mem_branch:	in std_logic_vector(1 downto 0);
			
			mem_d3_sel:	in std_logic_vector(1 downto 0);
			ex_nullify: in std_logic;
			
			id_multi:	in std_logic;
			
			pc_sel:		out std_logic_vector(1 downto 0);
			
			d1_df_sel:	out std_logic_vector(2 downto 0);
			d2_df_sel:	out std_logic_vector(2 downto 0);

			alu_sel: 	out std_logic_vector(1 downto 0);
			alu_a_sel: 	out std_logic_vector(1 downto 0); 
			alu_b_sel: 	out std_logic_vector(1 downto 0);
			c_w_en: 		out std_logic;
			z_w_en: 		out std_logic;
			
			rf_w_en:		out std_logic;			 			 
			rf_a1:		out std_logic_vector(2 downto 0);
			rf_a2:		out std_logic_vector(2 downto 0);
			rf_a3:		out std_logic_vector(2 downto 0);
			d3_sel:		out std_logic_vector(1 downto 0);
			
			ram_w_en:	out std_logic;
			
			branch:     out std_logic_vector(1 downto 0);
			lw_stall: 	out std_logic;
			k:			 	out std_logic;
			multi_stall:out std_logic;
			id_nullify:	out std_logic);
end component;

component IF_Reg is
	port (rst, clk, en: in std_logic;
			pc_in			: in std_logic_vector(15 downto 0);
			ir_in			: in std_logic_vector(15 downto 0);
			pc_out		: out std_logic_vector(15 downto 0);
			ir_out		: out std_logic_vector(15 downto 0));
end component;

component ID_Reg is
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
end component;

component OR_Reg is
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
end component;

component EX_Reg is
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
end component;

component MEM_Reg is
	port (rst, clk: 	in std_logic;
	
			alu_in: 		in std_logic_vector(15 downto 0);
			alu_out: 	out std_logic_vector(15 downto 0);
			
			RAM_in: 		in std_logic_vector(15 downto 0);
			RAM_out: 	out std_logic_vector(15 downto 0);
			
			MEM_in: 		in std_logic_vector(10 downto 0);
			MEM_out: 	out std_logic_vector(10 downto 0));
end component;

signal pc_in, pc_out					: std_logic_vector(15 downto 0);
signal pc_sel							: std_logic_vector(1 downto 0):= "00";

signal adder_out_1,adder_out		: std_logic_vector(15 downto 0);	
signal adder_a_2,adder_b_2,adder_out_2	: std_logic_vector(15 downto 0);	
signal adder_sel_2					: std_logic;	
signal se6_alu_in						: std_logic_vector(15 downto 0);	
signal se6_pc_in,se9_pc_in,K		: std_logic_vector(15 downto 0);	
signal rom_out							: std_logic_vector(15 downto 0);	

signal cz_en,multi_stall			: std_logic;

signal rf_w_en							: std_logic;	
signal rf_d1,rf_d2,r7_in			: std_logic_vector(15 downto 0);	
signal rf_a3							: std_logic_vector(2 downto 0);	
signal rf_d3							: std_logic_vector(15 downto 0);	
signal r7_sel							: std_logic_vector(1 downto 0):= "00";

signal alu_out, alu_a, alu_b		: std_logic_vector(15 downto 0);
signal c_flag_in, z_flag_in		: std_logic;
signal c_flag_out, z_flag_out		: std_logic;
signal beq_w							: std_logic;

signal ram_out							: std_logic_vector(15 downto 0);	

signal pc_en,if_en,id_en			: std_logic:= '1'; 
signal C,Z								: std_logic;

-------------Interface Reg signals---------------

signal if_pc_out, if_ir_out		: std_logic_vector(15 downto 0);
signal id_pc_out, id_ir_out		: std_logic_vector(15 downto 0);
signal or_pc_out, or_ir_out		: std_logic_vector(15 downto 0);
signal ex_pc_out, ex_ir_out		: std_logic_vector(15 downto 0);

signal d1_df_sel,d2_df_sel			: std_logic_vector(2 downto 0);
signal d1_sel, d2_sel				: std_logic_vector(2 downto 0);
signal id_d1_sel,id_d2_sel 		: std_logic_vector(2 downto 0);

signal ID_out							: std_logic_vector(27 downto 0);
signal OR_out							: std_logic_vector(20 downto 0);
signal EX_out							: std_logic_vector(13 downto 0);
signal MEM_out							: std_logic_vector(10 downto 0);

signal id_k,id_multi,id_nullify	: std_logic;
signal id_pc_sel						: std_logic_vector(1 downto 0);
signal or_branch						: std_logic_vector(1 downto 0);
signal or_nullify						: std_logic;
signal d1_in, d2_in					: std_logic_vector(15 downto 0);
signal d1_out, d2_out				: std_logic_vector(15 downto 0);
signal ex_d2_out						: std_logic_vector(15 downto 0);
signal ex_alu_out						: std_logic_vector(15 downto 0);
signal mem_alu_out, mem_ram_out	: std_logic_vector(15 downto 0);

------------------SIGNALS-----------------
signal adder_sel		: std_logic_vector(1 downto 0);

signal alu_sel			: std_logic_vector(1 downto 0);
signal alu_a_sel		: std_logic_vector(1 downto 0); 
signal alu_b_sel		: std_logic_vector(1 downto 0);
signal c_w_en			: std_logic:='0';
signal z_w_en			: std_logic:='0';


signal id_alu_sel		: std_logic_vector(1 downto 0);
signal id_alu_a_sel	: std_logic_vector(1 downto 0); 
signal id_alu_b_sel	: std_logic_vector(1 downto 0);
signal id_c_w			: std_logic:='0';
signal id_z_w			: std_logic:='0';

signal id_rf_w			: std_logic:='0';			 			 
signal id_rf_a1		: std_logic_vector(2 downto 0);
signal id_rf_a2		: std_logic_vector(2 downto 0);
signal id_rf_a3		: std_logic_vector(2 downto 0);
signal id_d3_sel		: std_logic_vector(1 downto 0);

signal id_ram_w		: std_logic:='0';
signal id_branch 		: std_logic_vector(1 downto 0);

signal d3_sel		   : std_logic_vector(1 downto 0);

signal id_lw_stall	: std_logic;
signal lw_stall		: std_logic;
 
begin

--------------------------------------------PC----------------------------------------------
				
	PC: Reg port map(pc_in, pc_out, rst, clk, pc_en);	
	
	MUX_PC:		MUX  	generic map(16,2)
							port map(i(0) 	=> adder_out, 
										i(1) 	=> alu_out,
										i(2) 	=> ram_out,
										i(3) 	=> X"XXXX",
										sel	=> pc_sel and (cz_en & cz_en), 
										o    	=> pc_in);
										
	adder_out_1 	<= pc_out + X"0001";
	adder_out_2 	<= adder_a_2 + adder_b_2;
	
	MUX_adder_a1:MUX 	generic map(16,1)
							port map(i(0) 	=> se6_pc_in,
										i(1) 	=> se9_pc_in,
										sel(0)	=> adder_sel_2, 
										o    	=> adder_a_2);
	
	MUX_adder_b1:MUX 	generic map(16,1)
							port map(i(0) 	=> or_pc_out,
										i(1) 	=> if_pc_out,
										sel(0)	=> adder_sel_2, 
										o    	=> adder_b_2);
	MUX_adder:	MUX 	generic map(16,2)
							port map(i(0) 	=> adder_out_1, 
										i(1) 	=> adder_out_2,
										i(2) 	=> d2_in,
										i(3) 	=> X"XXXX",
										sel	=> adder_sel, 
										o    	=> adder_out);
					  		
	add_mux: adder_mux port map(ID_out(22 downto 21) and (ID_out(12) & ID_out(12)),		 --JLR
										 or_branch,										 --BEQ
										 id_branch and (id_rf_w & id_rf_w),		 --JAL
										 adder_sel_2,
										 adder_sel);
										 
	SE6_PC: SE	generic map(6,16)
				port map(or_ir_out(5 downto 0), se6_pc_in);	--BEQ
					
	SE9_PC: SE	generic map(9,16)
				port map(if_ir_out(8 downto 0), se9_pc_in);	--JAL
				
				
	pc_mux_sel: process(all)
	begin
	
		if OR_out(18 downto 17) = "01" and (OR_out(6) and cz_en and beq_w) = '1' then --RF_W_EN
			pc_sel <= "01";
		elsif EX_out(8 downto 7) = "10" and EX_out(6) = '1' then
			pc_sel <= "10";
		else
			pc_sel <= "00";
		end if;
	
	end process;
														 
----------------------------------------MEMORY----------------------------------------------
				
	ROM_0: ROM port map(pc_out, rom_out);	
	
------------------------------------IF interface Register-----------------------------------

	IF_R: IF_Reg port map(rst, clk, if_en, pc_out, rom_out, if_pc_out, if_ir_out);	
	
------------------------------------------DECODER-------------------------------------------

	D: decoder port map(	rst, clk, 
								if_ir_out,
								c_flag_out, z_flag_out,
								
								id_ir_out,
								ID_out(12),					--id_rf_w
								ID_out(5 downto 3),		--id_rf_a3
								
								or_ir_out,
								OR_out(6) and cz_en,		--or_rf_w
								OR_out(5 downto 3),		--or_rf_a3
								
								ex_ir_out,
								EX_out(6),					--ex_rf_w
								EX_out(5 downto 3),		--ex_rf_a3
								
								MEM_out(5),					--mem_w_en
								MEM_out(4 downto 2),
								
								ID_out(22 downto 21),	--id branch
								OR_out(16 downto 15),	--or branch
								EX_out(10 downto 9),		--ex branch
								MEM_out(7 downto 6),		--mem brabch
								
								MEM_out(1 downto 0),		--mem_d3_sel
								EX_out(11),
								
								ID_out(26),
								
								id_pc_sel,
								
								d1_df_sel,
								d2_df_sel,

								id_alu_sel,
								id_alu_a_sel,
								id_alu_b_sel,
								id_c_w,
								id_z_w,
			
								id_rf_w,	 			 
								id_rf_a1,
								id_rf_a2,
								id_rf_a3,
								id_d3_sel,
						
								id_ram_w,
								
								id_branch,
								id_lw_stall,
								id_k,
								multi_stall,
								id_nullify);		
				
------------------------------------ID interface Register-----------------------------------
	
	ID_R: ID_Reg port map(rst, clk, '1', if_pc_out, if_ir_out, id_pc_out, id_ir_out,
								
								 d1_df_in 	=> d1_df_sel,
								 d2_df_in 	=> d2_df_sel,
								 d1_df_sel	=> id_d1_sel,
								 d2_df_sel 	=> id_d2_sel,
								 
								 ID_in(27)				=> id_nullify,
								 ID_in(26)				=>	multi_stall,
								 ID_in(25)				=>	id_k,
								 ID_in(24 downto 23) => id_pc_sel,
								 ID_in(22 downto 21)	=> id_branch,
								 ID_in(20 downto 19)	=> id_alu_sel,
								 ID_in(18 downto 17)	=> id_alu_a_sel,
								 ID_in(16 downto 15)	=> id_alu_b_sel,
								 ID_in(14) 				=> id_c_w,
								 ID_in(13)			 	=> id_z_w,
								 
								 ID_in(12) 				=> id_rf_w,
								 ID_in(11 downto 9)	=> id_rf_a1,
								 ID_in(8 downto 6) 	=> id_rf_a2,
								 ID_in(5 downto 3) 	=> id_rf_a3,
								 ID_in(2 downto 1) 	=> id_d3_sel,
								 
								 ID_in(0) 			 	=> id_ram_w,
								 ID_out => ID_out);
								 
	lw_stall <= id_lw_stall;							 
	LW_stall_process:process(all)
	begin
		if multi_stall = '1' and EX_out(8 downto 7) = "10" then
			pc_en <= '1';
			if_en <= '0';
		elsif lw_stall = '1' or multi_stall = '1' then
			pc_en <= '0';
			if_en <= '0';
		else
			pc_en <= '1';
			if_en <= '1';	
		end if;
	
	end process;
								 
---------------------------------------Register File------------------------------------------

	rf_w_en <= MEM_out(5);
 	rf_a3	  <= MEM_out(4 downto 2);
	d3_sel  <= MEM_out(1 downto 0);
	r7_in   <= EX_pc_out;
	
	r: reg_file port map(ID_out(11 downto 9),
								ID_out(8 downto 6),
								rf_a3,
								rf_d3,
								rst,clk,
								rf_w_en,rf_d1,rf_d2,EX_out(11),r7_in,R7_out,r0_out,r1_out);
								
	MUX_d3:	MUX 		generic map(16,1)
							port map(i(0) => mem_alu_out, 
										i(1) => mem_ram_out,					
										sel(0)  => d3_sel(0), 
										o    => rf_d3);
										
	
-------------------------------------OR interface Register------------------------------------
	
	OR_R: OR_Reg port map(rst, clk, '1', id_pc_out, id_ir_out, or_pc_out, or_ir_out,
								 d1_in,
								 d2_in,
								 d1_out,
								 d2_out,
								 
								 OR_in(20)				=> or_nullify,					--nullify
								 OR_in(19)				=> ID_out(25),					--K
								 OR_in(18 downto 17) => ID_out(24 downto 23) and (or_nullify&or_nullify),	--PC sel
								 OR_in(16 downto 15) => ID_out(22 downto 21) and (or_nullify&or_nullify),	--Branch
								 
								 OR_in(14 downto 13) => ID_out(20 downto 19),	--alu_sel
								 OR_in(12 downto 11) => ID_out(18 downto 17),	--alu_a_sel
								 OR_in(10 downto 9)  => ID_out(16 downto 15),	--alu_b_sel
								 OR_in(8) 				=> ID_out(14) and or_nullify,--c_w_en
								 OR_in(7) 				=> ID_out(13) and or_nullify,--z_w_en
								 
								 OR_in(6)				=> ID_out(12) and or_nullify,--rf_w_en
								 OR_in(5 downto 3)	=> ID_out(5 downto 3),		--rf_a3
								 OR_in(2 downto 1)	=> ID_out(2 downto 1),		--d3_sel
								 
								 OR_in(0)				=> ID_out(0) and or_nullify ,--ram_w_en
								 OR_out => OR_out);		
							
	MUX_d1:MUX 			generic map(16,3)
							port map(i(0) 	=> rf_d1, 
										i(1) 	=> alu_out,
										i(2) 	=> ex_alu_out,
										i(3) 	=> mem_alu_out,
										i(4) 	=> ram_out,
										i(5)	=> mem_ram_out,
										i(6)	=> id_pc_out,
										i(7)	=> (others => 'X'),
										sel   => d1_sel, 
										o    	=> d1_in);		
										
	MUX_d2:MUX 			generic map(16,3)
							port map(i(0) 	=> rf_d2, 
										i(1) 	=> alu_out,
										i(2) 	=> ex_alu_out,
										i(3) 	=> mem_alu_out,
										i(4) 	=> ram_out,
										i(5)	=> mem_ram_out,
										i(6)	=> id_pc_out,
										i(7)	=> (others => 'X'),
										sel   => d2_sel, 
										o    	=> d2_in);
										
	d1_d2_MUX: process(all)
	variable or_rf_a3	: std_logic_vector(2 downto 0);
	variable rf_a1		: std_logic_vector(2 downto 0);
	variable rf_a2		: std_logic_vector(2 downto 0);
	variable op			: std_logic_vector(3 downto 0);
	begin
	
		or_rf_a3 := OR_out(5 downto 3);
		rf_a1		:= ID_out(11 downto 9);
		rf_a2		:= ID_out(8 downto 6);
		op			:= or_ir_out(15 downto 12);
		
		if (op = "0000" or op = "0010") and (or_ir_out(1) or or_ir_out(0)) = '1' then
			if rf_a1 = or_rf_a3 and cz_en = '1' then
				d1_sel <= "001";
			else
				d1_sel <= id_d1_sel;
			end if;
			
			if rf_a2 = or_rf_a3 and cz_en = '1' then
				d2_sel <= "001";
			else
				d2_sel <= id_d2_sel;
			end if;
			
			if or_rf_a3 = "111" and cz_en = '1' and OR_out(20) ='1' then
				or_nullify <= '0';
			else
				or_nullify <= ID_out(27);
			end if;
		else
			d1_sel <= id_d1_sel;
			d2_sel <= id_d2_sel;
			or_nullify <= ID_out(27);
		end if;
				
	end process;

-------------------------------------------ALU-----------------------------------------------

	alU_a_sel <= OR_out(12 downto 11);
	alu_b_sel <= OR_out(10 downto 9);
	alu_sel   <= OR_out(14 downto 13);
	c_w_en	 <= OR_out(8);
	z_w_en	 <= OR_out(7);
	
	alu_0: ALU port map(alu_a, alu_b,alu_sel,alu_out,c_flag_in,z_flag_in);
	MUX_alu_a:	MUX 	generic map(16,2)
							port map(i(0) 	=> d1_out, 
										i(1)	=> X"0001",
										i(2)(15 downto 7) => or_ir_out(8 downto 0),i(2)(6 downto 0)=> (others => '0'),
										i(3)	=> or_pc_out,
										sel=> alu_a_sel, 
										o    	=> alu_a);
	MUX_alu_b:	MUX 	generic map(16,2)
							port map(i(0) => d2_out, 
										i(1) => se6_alu_in,
										i(2) => K,
										i(3) => or_pc_out,
										sel  => alu_b_sel, 
										o    => alu_b);
	MUX_K: 		MUX 	generic map(16,1)
							port map(i(0) => X"0000", 
										i(1) => X"0001",
										sel(0)=>OR_out(19), 
										o    => K);										
	SE6_alu: SE	generic map(6,16)
				port map(or_ir_out(5 downto 0), se6_alu_in);
					

	flag: Flags port map(c_flag_in, z_flag_in, c_flag_out, z_flag_out, rst, clk, 
								c_w_en, z_w_en,
								or_ir_out,
								ex_ir_out,
								ram_out,
								cz_en);	
						
	beq_compare: process(all)
	begin
		if OR_out(16 downto 15) = "01" and OR_out(20) = '1' then
			or_branch <= OR_out(16 downto 15) and (z_flag_in & z_flag_in);
		else
			or_branch <= OR_out(16 downto 15);
		end if;
	end process;

		
----------------------------------EXECUTE interface Register---------------------------------

	EX_R: EX_Reg port map(rst, clk, or_pc_out, or_ir_out, ex_pc_out, ex_ir_out,
								 
								 d2_out,
								 ex_d2_out,
								 
								 alu_out,
								 ex_alu_out,
								 
								 EX_in(13)				=> c_flag_in,
								 EX_in(12)				=> z_flag_in,
								 EX_in(11)				=> OR_out(20) and beq_w,								--nullify
								 EX_in(10 downto 9)	=> or_branch and (beq_w & beq_w),	--Branch
								 EX_in(8 downto 7) 	=> OR_out(18 downto 17) and (beq_w & beq_w) ,--PC sel
								 EX_in(6)				=> OR_out(6) and cz_en and beq_w,	--rf_w_en
								 EX_in(5 downto 3)	=> OR_out(5 downto 3),					--rf_a3
								 EX_in(2 downto 1)	=> OR_out(2 downto 1),					--d3_sel
								 
								 EX_in(0)				=> OR_out(0) and beq_w,					--ram_w_en
								 EX_out => EX_out);
								 
	beq_process: process(all)
	begin
		if EX_out(10 downto 9) = "01" or MEM_out(7 downto 6) = "01" then
			beq_w <= '0';
		else
			beq_w <= '1';
		end if;
	end process;
	
------------------------------------------RAM-----------------------------------------------
				
	RAM_0: RAM port map(ex_d2_out, ex_alu_out, EX_out(0), clk, ram_out);	
		
----------------------------------MEMORY interface Register---------------------------------
		
	MEM_R: MEM_Reg port map(rst, clk,
	
									ex_alu_out,
									mem_alu_out,
									ram_out,
									mem_ram_out,
									
									MEM_in(10)				=> c_flag_out,					--C
									MEM_in(9)				=> z_flag_out,					--Z
									MEM_in(8)				=>	EX_out(11),					--nullify
									MEM_in(7 downto 6)	=> EX_out(10 downto 9),		--Branch		
									MEM_in(5)				=> EX_out(6),					--rf_w_en
									MEM_in(4 downto 2)	=> EX_out(5 downto 3),		--rf_a3
									MEM_in(1 downto 0)	=> EX_out(2 downto 1),		--d3_sel
									MEM_out => MEM_out);	
									
	C_flag: FF port map(MEM_out(10), C, rst, clk, MEM_out(8));			
	Z_flag: FF port map(MEM_out(9), Z , rst, clk, MEM_out(8));
	C_out <= C;
	Z_out <= Z;
	
end struct;

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity adder_mux is
	port ( JLR:				in std_logic_vector(1 downto 0);
			 BEQ:				in std_logic_vector(1 downto 0);
			 JAL:				in std_logic_vector(1 downto 0);
			 adder_sel_2:	out std_logic;
			 adder_sel:		out std_logic_vector(1 downto 0));
end entity;  

architecture struct of adder_mux is
begin

	process(all)
	begin
		if BEQ = "01" then			--BEQ
			adder_sel 	<= "01";
			adder_sel_2	<= '0';
		elsif JLR = "11" then		--JLR
			adder_sel 	<= "10";
			adder_sel_2	<= 'X';			
		elsif JAL = "10" then		--JAL
			adder_sel 	<= "01";
			adder_sel_2	<= '1';
		else								--HKT
			adder_sel <= "00";
			adder_sel_2	<= 'X';
		end if;
	end process;

end struct;

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Flags is
	port ( c_flag_in, z_flag_in  	: in std_logic;
			 c_flag_out, z_flag_out	: out std_logic;
			 rst, clk				  	: in std_logic;
			 c_W_en, z_w_en			: in std_logic;
			 or_ir_out					: in std_logic_vector(15 downto 0);
			 ex_ir_out					: in std_logic_vector(15 downto 0);
			 ram_out						: in std_logic_vector(15 downto 0);
			 w_en							: out std_logic);
end entity; 

architecture struct of Flags is
component FF is
	port ( D: 		in std_logic;
			 Q: 		out std_logic;
			 clr,clk:in std_logic;
			 en: 		in std_logic);
end component;

signal c_en, z_en, w, z, z_out : std_logic;

begin

	C_flag: FF port map(c_flag_in, c_flag_out, rst, clk, c_en);
				
	Z_flag: FF port map(z, z_out , rst, clk, z_en);
	
	c_en <= c_w_en and w;
	
	w_en <= w;
	
	process(all)
	begin
		if or_ir_out(15 downto 12) = "0000" or or_ir_out(15 downto 12) = "0010" then
			if (or_ir_out(1) = '1' and C_flag_out = '1') or
				(or_ir_out(0) = '1' and z_flag_out = '1') or
				(or_ir_out(1 downto 0) = "00") then
				
				w <= '1';	
			else
				w <= '0';	
			end if;
		else
			w <= '1';
		end if;


		if ex_ir_out(15 downto 12) = "0100" then
			if (ram_out) = X"0000" then 
				z_flag_out    <= '1';
			else
				z_flag_out	  <= '0';
			end if;
			
			if (ram_out) = X"0000" and (z_w_en and w) = '0' then
				z 	  <= '1';
				z_en <= '1';
			else
				z_en	<= z_w_en and w;
				z    	<= z_flag_in;
			end if;

		else
			z_en 		  <= z_w_en and w;
			z    		  <= z_flag_in;
			z_flag_out <= z_out;
		end if;
	
	end process;
	
end struct;
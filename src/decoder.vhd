library ieee; 
use ieee.std_logic_1164.all; 

entity decoder is
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
end entity;

architecture struct of decoder is

component priority_encoder is 
	port(enco_in	: in std_logic_vector(7 downto 0);
		  decod_out	: out std_logic_vector(7 downto 0);
		  enco_out	: out std_logic_vector(2 downto 0));
end component;

component Reg is
	generic (width: integer:=16);
	port ( D: in std_logic_vector((width-1) downto 0);
			 Q: out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

constant add: std_logic_vector(3 downto 0):= "0000";
constant adi: std_logic_vector(3 downto 0):= "0001";
constant ndu: std_logic_vector(3 downto 0):= "0010";
constant lhi: std_logic_vector(3 downto 0):= "0011";
constant lw	: std_logic_vector(3 downto 0):= "0100";
constant sw	: std_logic_vector(3 downto 0):= "0101";
constant beq: std_logic_vector(3 downto 0):= "1100";
constant jal: std_logic_vector(3 downto 0):= "1000";
constant jlr: std_logic_vector(3 downto 0):= "1001";
constant lm	: std_logic_vector(3 downto 0):= "0110";
constant sm	: std_logic_vector(3 downto 0):= "0111";


signal enco_in				: std_logic_vector(7 downto 0);
signal reg_in,reg_out	: std_logic_vector(7 downto 0);
signal decod_and_reg,decod_out		: std_logic_vector(7 downto 0);
signal addr_out			: std_logic_vector(2 downto 0);	
signal op,id_op			: std_logic_vector(3 downto 0);
signal id_adc,nullify	: std_logic;
signal rf_w_op,ram_w_op	: std_logic;
signal c_w_op,z_w_op		: std_logic;
signal enco_en,reg_sel	: std_logic;

begin
	
	op <= ir_in(15 downto 12);
	id_op <= id_ir_out(15 downto 12);
	id_adc <= '1' when (id_op = add or id_op = ndu) and (id_ir_out(1) = '1' or id_ir_out(0) = '1') else		
				 '0';														--If next instruction is Conditonal AL 
	id_nullify 	<= nullify;
	rf_w_en 		<= rf_w_op and nullify;
	ram_w_en		<= ram_w_op and nullify;
	c_w_en		<= c_w_op and nullify;
	z_w_en		<= z_w_op and nullify;
	
	Instruction:process(all)
	begin
	
	---------------------------------------ADD/NDU------------------------------------		
		if op = add or op = ndu then		
			--alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "00";
			k				<= 'X';
			c_w_op		<= '1';
			z_w_op		<= '1';
			
			rf_w_op		<= '1';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= ir_in(8 downto 6);
			rf_a3			<= ir_in(5 downto 3);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
			
			if op = add then
				alu_sel 		<=	"00";
			else 
				alu_sel 		<=	"01";
			end if;

	----------------------------------------ADI--------------------------------------		
			
		elsif op = adi then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "01";
			k				<= 'X';
			c_w_op		<= '1';
			z_w_op		<= '1';
			
			rf_w_op		<= '1';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= (others => 'X');
			rf_a3			<= ir_in(8 downto 6);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
			
	----------------------------------------LHI--------------------------------------		
	
		elsif op = lhi then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "10";
			alu_b_sel	<= "10";
			k				<= '0';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '1';			 
			rf_a1			<= (others => 'X');
			rf_a2			<= (others => 'X');
			rf_a3			<= ir_in(11 downto 9);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
		
	----------------------------------------LW---------------------------------------		
	
		elsif op = lw then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "01";
			k				<= 'X';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '1';			 
			rf_a1			<= ir_in(8 downto 6);
			rf_a2			<= (others => 'X');
			rf_a3			<= ir_in(11 downto 9);
			d3_sel		<= "01";
	
			ram_w_op		<= '0';
			
	----------------------------------------SW---------------------------------------		
		
		elsif op = sw then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "01";
			k				<= 'X';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '0';			 
			rf_a1			<= ir_in(8 downto 6);
			rf_a2			<= ir_in(11 downto 9);
			rf_a3			<= (others => 'X');
			d3_sel		<= (others => 'X');
	
			ram_w_op		<= '1';
			
	----------------------------------------JAL---------------------------------------		
		
		elsif op = jal then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "11";
			alu_b_sel	<= "10";
			k				<= '0';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '1';			 
			rf_a1			<= (others => 'X');
			rf_a2			<= (others => 'X');
			rf_a3			<= ir_in(11 downto 9);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
			
	----------------------------------------JLR---------------------------------------		
			
		elsif op = jlr then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "11";
			alu_b_sel	<= "10";
			k				<= '0';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '1';			 
			rf_a1			<= (others => 'X');
			rf_a2			<= ir_in(8 downto 6);
			rf_a3			<= ir_in(11 downto 9);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
			
	----------------------------------------BEQ---------------------------------------		
		
		elsif op = beq then
			alu_sel 		<=	"10"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "00";
			k				<= 'X';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '0';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= ir_in(8 downto 6);
			rf_a3			<= (others => 'X');
			d3_sel		<= (others => 'X');
	
			ram_w_op		<= '0';
			
	-----------------------------------------LM----------------------------------------		
	
		elsif op = lm then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "10";
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '1';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= (others => 'X');
			rf_a3			<= addr_out;
			d3_sel		<= "01";
	
			ram_w_op		<= '0';
		
			if not (id_op = lm and id_multi = '1') then
				k 	<= '0';
			else
				k  <= '1';
			end if;
	
	-----------------------------------------SM----------------------------------------		
	
		elsif op = sm then
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "10";
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '0';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= addr_out;
			rf_a3			<= (others => 'X');
			d3_sel		<= "XX";
	
			ram_w_op		<= '1';
		
			if not (id_op = sm and id_multi = '1') then
				k 	<= '0';
			else
				k  <= '1';
			end if;
		
		else
			alu_sel 		<=	"00"; 
			alu_a_sel	<= "00";
			alu_b_sel	<= "00";
			k				<= 'X';
			c_w_op		<= '0';
			z_w_op		<= '0';
			
			rf_w_op		<= '0';			 
			rf_a1			<= ir_in(11 downto 9);
			rf_a2			<= ir_in(8 downto 6);
			rf_a3			<= ir_in(5 downto 3);
			d3_sel		<= "00";
	
			ram_w_op		<= '0';
			
		end if;
	end process;
	
	LM_SM: process(all)
	begin
	
		if (op = lm or op = sm) and not ((id_op = lm or id_op = sm) and id_multi = '1') then
			enco_in 		<= ir_in(7 downto 0);
		elsif (op = lm or op = sm) and not (reg_out = X"00") then
			enco_in 		<= reg_out;
		else	
			enco_in <= X"00";
		end if;	
			
		if (op = lm or op = sm) and not (decod_and_reg = X"00"	) then
			multi_stall <= '1' and nullify;
		else
			multi_stall <= '0';
		end if;
	end process;
	
	decod_and_reg	<=	decod_out and enco_in;
	reg_in			<= decod_and_reg;
	enco_decod: priority_encoder port map(enco_in, decod_out, addr_out);
	enco_reg: Reg 	generic map(8)
						port map(reg_in, reg_out, rst, clk, not lw_stall);	
	
	D1_Data_Forwarding:process(all)
	begin
	----------------------------------------D1 Data Forwarding---------------------------------------------

			if (op = lm or op = sm) and (id_op = lm or id_op = sm) and id_multi = '1' then
				d1_df_sel <= "001";
			elsif op = add or op = ndu or op = adi or op = lw or op = sw  or op = beq or op = lm or op = sm then	--ADD/NDU/ADI/LW/SW/BEQ/LM
				if rf_a1 = id_rf_a3 and id_rf_w = '1' and (id_op = lw or id_op = lm) then
					d1_df_sel <= "100";
				elsif rf_a1 = id_rf_a3 and id_rf_w = '1' and id_adc = '0' then
					d1_df_sel <= "001";
					
					
				elsif rf_a1 = or_rf_a3 and or_rf_w = '1' and (or_ir_out(15 downto 12) = lw or or_ir_out(15 downto 12) = lm) then
					d1_df_sel <= "100";
				elsif rf_a1 = or_rf_a3 and or_rf_w = '1' then
					d1_df_sel <= "010";
					
				
				elsif rf_a1 = ex_rf_a3 and ex_rf_w = '1' and (ex_ir_out(15 downto 12) = lw or ex_ir_out(15 downto 12) = lm) then
					d1_df_sel <= "101";
				elsif rf_a1 = ex_rf_a3 and ex_rf_w = '1' then
					d1_df_sel <= "011";
				
				elsif rf_a1 = "111" then
					d1_df_sel <= "110";
					
				else
					d1_df_sel <= "000";
				end if;

			else
				d1_df_sel <= "000";
			end if;
			
	end process;
	
	D2_Data_Forwarding:process(all)
	begin
	----------------------------------------D2 Data Forwarding---------------------------------------------

			if op = add or op = ndu or op = sw or op = beq or op = jlr or op = sm then								--ADD/NDU
				if rf_a2 = id_rf_a3 and id_rf_w = '1' and (id_op = lw or id_op = lm) then
					d2_df_sel <= "100";
				elsif rf_a2 = id_rf_a3 and id_rf_w = '1' and id_adc = '0' then
					d2_df_sel <= "001";	
					
				elsif rf_a2 = or_rf_a3 and or_rf_w = '1' and (or_ir_out(15 downto 12) = lw or or_ir_out(15 downto 12) = lm) then
					d2_df_sel <= "100";
				elsif rf_a2 = or_rf_a3 and or_rf_w = '1' then
					d2_df_sel <= "010";
					
					
				elsif rf_a2 = ex_rf_a3 and ex_rf_w = '1' and (ex_ir_out(15 downto 12) = lw or ex_ir_out(15 downto 12) = lm) then
					d2_df_sel <= "101";
				elsif rf_a2 = ex_rf_a3 and ex_rf_w = '1' then
					d2_df_sel <= "011";
				
				elsif rf_a2 = "111" then
					d2_df_sel <= "110";	
					
				else
					d2_df_sel <= "000";
				end if;

			else
				d2_df_sel <= "000";
			end if;
			
	end process;
	
	Stalling:process(all)
	begin
	
		if (rf_a1 = id_rf_a3 or rf_a2 = id_rf_a3) and id_rf_w = '1' and (id_op = lw or (id_op = lm and id_multi = '0')) then 
			lw_stall <= '1';
		else
			lw_stall <= '0';
		end if;
	
	end process;
	
	R7_process:process(all)
	begin
	
		if (op = add or op = ndu or op = adi) and rf_a3 = "111" then
			pc_sel 	<= "01";
		elsif (op = lw or op = lm) and rf_a3 = "111" then
			pc_sel 	<= "10";
		else
			pc_sel 	<= "00";
		end if;
	end process;
				 
	Branch_Instruct:process(all)
	begin
		if op = beq then
			branch <= "01";
		elsif op = jal then
			branch <= "10";
		elsif op = jlr then
			branch <= "11";
		else 
			branch <= "00";
		end if;
	end process;

	write_enable:process(all)
	begin
	
	if not(op = lm) or (op = lm and not(id_op = lm and id_multi = '1')) then
		if (mem_rf_a3 = "111" and mem_rf_w = '1' and mem_d3_sel = "01") then
			nullify <= '0';
		elsif ((ex_rf_a3 = "111") and ex_rf_w = '1') or (ex_branch = "01" and ex_nullify = '1') then
			nullify <= '0';	
		elsif (or_rf_a3 = "111" or or_branch = "11") and or_rf_w = '1' then
			nullify <= '0';
		elsif ((id_rf_a3 = "111" and id_adc = '0') or id_branch = "10" or id_branch = "11") and id_rf_w = '1' then
			nullify <= '0';
		elsif lw_stall = '1' then
			nullify <= '0';
		else
			nullify <= '1';
		end if;
	else
		nullify <= '1';
	end if;
	end process;
end struct;



library ieee; 
use ieee.std_logic_1164.all; 

entity priority_encoder is 
	port(enco_in	: in std_logic_vector(7 downto 0);
		  decod_out	: out std_logic_vector(7 downto 0);
		  enco_out	: out std_logic_vector(2 downto 0));
end entity;	

architecture struct of priority_encoder is
begin

	process(enco_in)
	begin
	if enco_in(7) then
		decod_out	<= not "10000000";
		enco_out 	<= "111";
	elsif enco_in(6) then
		decod_out	<= not"01000000";
		enco_out 	<= "110";
	elsif enco_in(5) then
		decod_out	<= not"00100000";
		enco_out 	<= "101";
	elsif enco_in(4) then
		decod_out	<= not"00010000";
		enco_out 	<= "100";
	elsif enco_in(3) then
		decod_out	<= not"00001000";
		enco_out 	<= "011";
	elsif enco_in(2) then
		decod_out	<= not"00000100";
		enco_out 	<= "010";
	elsif enco_in(1) then
		decod_out	<= not"00000010";
		enco_out 	<= "001";
	elsif enco_in(0) then
		decod_out	<= not"00000001";
		enco_out 	<= "000";
	else
		decod_out	<= (others => 'X');
		enco_out 	<= (others => 'X');
	end if;
	end process;

end struct;
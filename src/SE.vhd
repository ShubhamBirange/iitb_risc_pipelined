library ieee; 
use ieee.std_logic_1164.all;

entity SE is
generic (in_width: 	integer:=6;
			out_width: 	integer:=16);
	port (i: in std_logic_vector((in_width - 1) downto 0);
			o: out std_logic_vector((out_width - 1) downto 0));
end entity;

architecture struct of SE is
begin
	
	process(all)
	begin
		
		case i(in_width - 1) is
		when '0' =>
			o <= ((out_width -1) downto in_width => '0') & i;
			
	   when others =>
			o <= ((out_width -1) downto in_width => '1') & i;

		end case; 
	end process;

end struct;
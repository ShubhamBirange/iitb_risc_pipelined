library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bus_multiplexer_pkg is
        type bus_array is array(natural range <>) of std_logic_vector;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bus_multiplexer_pkg.all;

entity MUX is
        generic (bus_width : 	positive := 16;
                sel_width : 	positive := 3);
        port (  i : 		in bus_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
                sel :	in std_logic_vector(sel_width - 1 downto 0);
                o : 		out std_logic_vector(bus_width - 1 downto 0));
end MUX;

architecture dataflow of MUX is
begin
        o <= i(to_integer(unsigned(sel)));
end dataflow;
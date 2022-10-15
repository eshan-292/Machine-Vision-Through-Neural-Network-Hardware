library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity comparator is
    port (
        inp  : in std_logic_vector (15 downto 0)  := X"0000";
        outp : out std_logic_vector (15 downto 0) := X"0000"
    );
end comparator;

architecture Behavioral of comparator is

begin

    outp <= X"0000" when inp(15) = '1' else
        inp;

end Behavioral;
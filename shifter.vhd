library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    port (
        inp : in std_logic_vector (15 downto 0)  := X"0000";
        op  : out std_logic_vector (15 downto 0) := X"0000"
    );
end shifter;

architecture Behavioral of shifter is

begin

    op <= std_logic_vector(unsigned("11111" & inp(15 downto 5)) + 1) when inp(15) = '1' and inp(4 downto 0) /= "00000" else
    inp(15) & inp(15) & inp(15) & inp(15) & inp(15) & inp(15 downto 5);

end Behavioral;
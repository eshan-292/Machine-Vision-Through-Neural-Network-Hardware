-------------------------------- RAM ---------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram is
    port (
        --	Mstate	: in integer; --state of the FSM
        Mclk  : in std_logic                       := '0'; --clock
        Madr  : in std_logic_vector (7 downto 0)   := X"00"; --address
        Mdtin : in std_logic_vector (15 downto 0)  := X"0000"; --data to be written
        Mwe   : in std_logic                       := '0'; --write enable
        Mre   : in std_logic                       := '0'; --read enable
        Mout  : out std_logic_vector (15 downto 0) := X"0000" --data output
    );
end ram;

architecture rtl of ram is
    type mem is array(0 to 255) of std_logic_vector (15 downto 0); --array
    signal memory : mem := (others => (others => '0'));

begin
    Mout <= memory(to_integer(unsigned(Madr))) when Mre = '1' else X"0000";
    process (Mclk)
    begin
        if (Mwe = '1') and rising_edge(Mclk) then --write in the ram
            memory(to_integer(unsigned(Madr))) <= Mdtin;
        end if;
    end process;
end rtl;
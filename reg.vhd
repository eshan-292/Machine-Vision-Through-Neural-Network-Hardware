--------------------------- REGISTER-FILE ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg is
    port (
        Rdtin : in std_logic_vector (15 downto 0)  := X"0000"; --data input
        Rwe   : in std_logic                       := '0'; --write enable
        Rclk  : in std_logic                       := '0'; --clock
        Rdout : out std_logic_vector (15 downto 0) := X"0000" --data output
    );
end reg;

architecture rtl of reg is
    signal value : std_logic_vector(15 downto 0) := X"0000"; --data
begin
    Rdout <= value; --read from the register
    process (Rclk)
    begin
        if (Rwe = '1') and rising_edge(Rclk) then --write in the register
            value <= Rdtin;
        end if;
    end process;
end rtl;
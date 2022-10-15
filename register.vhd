--------------------------- reg_fileISTER-FILE ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg_file is
    port (
        Rrad1 : in std_logic_vector (3 downto 0)   := X"0"; --read address 1
        Rrad2 : in std_logic_vector (3 downto 0)   := X"0"; --read address 2
        Rwrad : in std_logic_vector (3 downto 0)   := X"0"; --write address
        Rdtin : in std_logic_vector (15 downto 0)  := X"0000"; --data input
        Rwe   : in std_logic                       := '0'; --write enable
        Rclk  : in std_logic                       := '0'; --clock
        Rout1 : out std_logic_vector (15 downto 0) := X"0000"; --data output 1
        Rout2 : out std_logic_vector (15 downto 0) := X"0000" --data output 2
    );
end reg_file;

architecture rtl of reg_file is
    type mem is array(0 to 15) of std_logic_vector (15 downto 0); --array
    signal memory : mem := (others => (others => '0'));
begin
    Rout1 <= memory(to_integer(unsigned(Rrad1))); --read from the reg_fileister fle
    Rout2 <= memory(to_integer(unsigned(Rrad2))); --read from the reg_fileister fle
    process (Rclk)
    begin
        if (Rwe = '1') and rising_edge(Rclk) then --write in the reg_fileister file
            memory(to_integer(unsigned(Rwrad))) <= Rdtin;
        end if;
    end process;
end rtl;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
    -- empty
end testbench;

architecture tb of testbench is
    constant num_cycle  : integer := 500000;
    constant clk_period : time    := 10 ns;

    component design is
        port (
            clk : in std_logic := '0'
        );
    end component;

    signal clock : std_logic := '0';

begin
    ----- Clock generator -----

    clkk : process
    begin
        for i in 0 to num_cycle loop
            clock <= not clock;
            wait for clk_period/2;
        end loop;
        wait;
    end process clkk;

    DUT : design port map(
        clk => clock
    );

    test : process
    begin
        assert false report lf & "************************************************************" & lf & "CODE Tested : Please Check Timing Diagram for more info!" & lf & "************************************************************" severity note;
        wait;
    end process test;

end tb;
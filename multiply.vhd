---------------------------- MULTIPLY -------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MUL is
    port (
        MlClk : in std_logic                      := '0'; --Clock
        Mlen  : in std_logic                      := '0'; --Enable
        MlFst : in std_logic_vector(15 downto 0)  := X"0000"; --operand 1
        MlSnd : in std_logic_vector(15 downto 0)  := X"0000"; --operand 2
        MlAdd : in std_logic_vector(15 downto 0)  := X"0000"; --Addend
        MlRes : out std_logic_vector(15 downto 0) := X"0000" --Result
        -- MlSgn : in std_logic                     := '0'; --Signed-Unsigned (Bit 22)
        -- MlAcm : in std_logic                     := '0'; --Accumulate (Bit 21)
        -- Ren   : out std_logic                    := '0' --Result Enable
    );
end MUL;

architecture rtl of MUL is
    -- signal prod : signed (31 downto 0) := X"00000000";
    -- signal res  : signed (31 downto 0) := X"00000000";
begin
    process (MlClk)
        variable prod : signed (31 downto 0) := X"00000000";
        variable res  : signed (31 downto 0) := X"00000000";
    begin
        if rising_edge(MlClk) and (Mlen = '1') then
            prod  := signed(MlFst) * signed(MlSnd);
            res   := signed(MlAdd) + prod;
            MlRes <= std_logic_vector(res(15 downto 0));
            -- Ren   <= '1';
        end if;
    end process;
end rtl;
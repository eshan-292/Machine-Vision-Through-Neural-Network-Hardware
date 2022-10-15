---------------------------- CONTROL-FSM ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FSM is
    port (
        Fclk          : in std_logic                        := '0'; --Clock
        ram_data_out  : in std_logic_vector(15 downto 0)    := X"0000"; --Reading ram value for the last layer of network
        State         : inout integer                       := 0; --FSM State
        rom_read_adr  : out std_logic_vector(15 downto 0)   := X"0000";
        mul_write_adr : inout std_logic_vector(7 downto 0)  := X"00";
        img_read_adr  : inout std_logic_vector(15 downto 0) := X"0000";
        count         : inout integer                       := 0; --Counter
        level         : inout std_logic                     := '0'; --Level of the network
        result        : out unsigned(3 downto 0)            := X"0" --Result of the Neural Network
        -- img_read_adr      : inout std_logic_vector(15 downto 0) := X"0000";
        -- wt_read_adr       : inout std_logic_vector(15 downto 0) := X"0000";
        -- bs_read_adr       : inout std_logic_vector(15 downto 0) := X"0000";
    );
end FSM;

architecture rtl of FSM is
    signal maxCnt, cnt_max_cnt : integer := 0;
    -- signal level, Mlen, reg_en               : std_logic                     := '0';
    -- signal img_read_adr, rom_read_adr        : std_logic_vector(15 downto 0) := X"0000";
    signal wt_read_adr : std_logic_vector(15 downto 0) := X"0400";
    signal bs_read_adr : std_logic_vector(15 downto 0) := X"CA80";
    signal max_value   : std_logic_vector(15 downto 0) := X"0000";
    signal max_counter : unsigned(3 downto 0)          := X"1";
    -- signal mul_write_adr                     : std_logic_vector(7 downto 0)  := X"00";
    -- signal mul_read_adr                                         : std_logic_vector(7 downto 0)  := X"01";
begin
    maxCnt <= 784 when level = '0' else 64;
    process (Fclk)
    begin
        if rising_edge(Fclk) then
            case State is
                when 0 =>
                    rom_read_adr  <= bs_read_adr;
                    bs_read_adr   <= std_logic_vector(unsigned(bs_read_adr) + 1);
                    mul_write_adr <= std_logic_vector(unsigned(mul_write_adr) + 1);
                    if (level = '1' and cnt_max_cnt = 10) then
                        State        <= 7;
                        img_read_adr <= X"0041";
                    else
                        State <= 3;
                    end if;
                when 3 =>
                    State <= 4;
                    -- rom_read_adr <= std_logic_vector(unsigned(wt_read_adr) - 1);
                when 4 =>
                    State <= 1;
                when 1 =>
                    rom_read_adr <= img_read_adr;
                    if (count = maxCnt - 1) then
                        if level = '0' then
                            img_read_adr <= X"0000";
                        else
                            img_read_adr <= X"0001";
                        end if;
                    else
                        img_read_adr <= std_logic_vector(unsigned(img_read_adr) + 1);
                    end if;

                    -- if (level = '0' and count = maxCnt - 1) or (level = '1' and count = maxCnt) then
                    --     img_read_adr <= X"0000";
                    -- else
                    --     img_read_adr <= std_logic_vector(unsigned(img_read_adr) + 1);
                    -- end if;
                    -- reg_en <= '0';
                    -- Mlen   <= '1';
                    State <= 5;
                when 5 =>
                    if (level = '0' and cnt_max_cnt = 63 and count = maxCnt) then
                        level       <= '1';
                        cnt_max_cnt <= 0;
                        count       <= 0;

                        -- if (level = '1' and cnt_max_cnt = 10) then
                        --     State <= 7;
                        -- end if;

                    end if;
                    State <= 2;
                when 2 =>
                    rom_read_adr <= wt_read_adr;
                    wt_read_adr  <= std_logic_vector(unsigned(wt_read_adr) + 1);
                    State        <= 6;
                when 6 =>
                    if count = maxCnt then
                        State       <= 0;
                        count       <= 1;
                        cnt_max_cnt <= cnt_max_cnt + 1;
                    else
                        if (count = 0 and level = '1') then
                            State <= 0;
                        else
                            State <= 1;
                        end if;
                        count <= count + 1;
                    end if;
                when others =>
                    rom_read_adr <= X"0000";
                    if (max_value < ram_data_out) then
                        max_value <= ram_data_out;
                        result    <= max_counter;
                    end if;
                    if (max_counter < 10) then
                        max_counter  <= max_counter + 1;
                        img_read_adr <= std_logic_vector(unsigned(img_read_adr) + 1);
                    end if;
            end case;
        end if;
    end process;
end rtl;
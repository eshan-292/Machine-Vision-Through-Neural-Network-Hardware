---------------------------- CONTROL -------------------------------

-- TODO: WASTE THE FIRST ADDRESS OF RAM and UPDATE IT IN State = 0

-- Check the logic for updation of ram_adr which is depoendent on both State and clk

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
    port (
        clk, level                : in std_logic                       := '0'; --reg_en from FSM
        State, count              : in integer                         := 0;
        rom_data, mul_write_adr   : in std_logic_vector(7 downto 0)    := X"00"; --ROM output and RAM address for multiplier output
        img_read_adr              : in std_logic_vector (7 downto 0)   := X"00"; -- Address of RAM to read for level 1, from FSM
        final, Mlres              : in std_logic_vector(15 downto 0)   := X"0000"; -- reg_out + bias -> shifter -> relu
        ram_adr                   : out std_logic_vector (7 downto 0)  := X"00"; -- RAM address
        ram_data_in, reg4_data_in : out std_logic_vector (15 downto 0) := X"0000"; -- RAM input value
        ram_write_enable          : out std_logic                      := '0';
        reg1_write_en, Mlen       : out std_logic                      := '0';
        reg2_write_en             : out std_logic                      := '0';
        reg3_write_en             : out std_logic                      := '0';
        reg4_write_en             : out std_logic                      := '0'
    );
end control;

architecture rtl of control is

    -- signal mul_fst                                                   : std_logic_vector(15 downto 0) := X"0000";
    signal im_addr : std_logic_vector(7 downto 0) := X"ff";
    signal wt_addr : std_logic_vector(7 downto 0) := X"fe";
    signal bs_addr : std_logic_vector(7 downto 0) := X"fd";
    -- signal rom_read_adr                                : std_logic_vector(15 downto 0) := X"0000";
    -- signal reg_read_adr, reg_write_adr                 : std_logic_vector(3 downto 0)  := X"0";
    -- signal bs_reg_adr                                  : std_logic_vector(3 downto 0)  := X"11"; --RESERVED FOR bsUMULATOR
    -- signal ram_read_adr1, ram_read_adr2, ram_adr : std_logic_vector(7 downto 0)  := X"00";
    -- signal ram_write_enable                                          : std_logic                     := '0';
    -- signal reg1_write_en, reg2_write_en, reg3_write_en, reg_write_en : std_logic                     := '0';
    -- signal reg_data_in, ram_data_in                                  : std_logic_vector(15 downto 0) := X"0000";
    -- signal reg1_data_out, reg2_data_out, reg3_data_out, reg_data_out : std_logic_vector(15 downto 0) := X"0000";
begin
    -- Reg1 for image, Reg2 for weight, Reg3 for bias, reg for bs
    -- shift_out = reg_data_out + ram_data_1

    -- ram_read_adr1 <= bs_addr when State = 3 else
    -- im_addr when level = '0' else
    -- std_logic_vector(unsigned(img_read_adr) + 1);

    -- ram_read_adr2 <= wt_addr;

    ram_data_in <= final when State = 0 else
    rom_data(7) & rom_data(7) & rom_data(7) & rom_data(7) & rom_data(7) & rom_data(7) & rom_data(7) & rom_data(7) & rom_data;

    ram_write_enable <= '0' when State = 1 or State = 2 or State = 4 or State = 7 else
    '1';

    ram_adr <= mul_write_adr when State = 0 else
    bs_addr when State = 3 or State = 4 else
    im_addr when State = 5 else
    im_addr when State = 2 and level = '0' else
    img_read_adr when State = 2 and level = '1' else
    wt_addr when State = 6 or State = 1 else
    img_read_adr;

    -- ram_adr <= wt_addr when State = 0 else
    --     mul_write_adr when State = 3 else
    --     bs_addr when (State = 1) and (count = 0) else
    --     wt_addr when State = 1 else
    --     im_addr when State = 2 else
    --     X"00";

    Mlen <= '1' when State = 5 else
    '0';

    reg4_write_en <= '1' when State = 2 or State = 3 else
    '0';
    reg4_data_in <= Mlres when State = 2 else
    X"0000";

    reg1_write_en <= '1' when State = 2 else
    '0';
    -- reg1_data_in <= ram_data_out;

    reg2_write_en <= '1' when State = 1 else
    '0';
    -- reg2_data_in <= ram_data_out;

    reg3_write_en <= '1' when State = 4 else
    '0';
    -- reg3_data_in <= ram_data_out;

    -- ram_write_enable <= '1' when State = 0 else
    -- '0';

    -- process (clk)
    -- begin
    --     if rising_edge(clk) and (State = 0) and (count = 0) then
    --         mul_write_adr <= mul_write_adr + '1';
    --     end if;
    -- end process
end rtl;
---------------------------- DESIGN -------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity design is
    port (
        clk : in std_logic := '0'
    );
end design;

architecture rtl of design is
    component MUL is
        port (
            MlClk : in std_logic                      := '0'; --Clock
            Mlen  : in std_logic                      := '0'; --Enable
            MlFst : in std_logic_vector(15 downto 0)  := X"0000"; --operand 1
            MlSnd : in std_logic_vector(15 downto 0)  := X"0000"; --operand 2
            MlAdd : in std_logic_vector(15 downto 0)  := X"0000"; --Addend
            MlRes : out std_logic_vector(15 downto 0) := X"0000" --Result
        );
    end component;

    component rom is
        generic (
            DATA_WIDTH            : integer := 8;
            IMAGE_SIZE            : integer := 784;
            WEIGHT_SIZE           : integer := 50816;
            BIAS_SIZE             : integer := 74;
            IMAGE_FILE_NAME       : string  := "imgdata_digit7.mif";
            WEIGHT_BIAS_FILE_NAME : string  := "weights_bias.mif"
        );
        port (
            Madr  : in std_logic_vector (15 downto 0) := X"0000"; --address
            Mre   : in std_logic                      := '0'; --read enable
            Mdata : out std_logic_vector (7 downto 0) := X"00" --data output
        );
    end component;

    component ram is
        port (
            --	Mstate	: in integer; --state of the FSM
            Mclk  : in std_logic                       := '0'; --clock
            Madr  : in std_logic_vector (7 downto 0)   := X"00"; --address
            Mdtin : in std_logic_vector (15 downto 0)  := X"0000"; --data to be written
            Mwe   : in std_logic                       := '0'; --write enable
            Mre   : in std_logic                       := '0'; --read enable
            Mout  : out std_logic_vector (15 downto 0) := X"0000" --data output
        );
    end component;

    component comparator is
        port (
            inp  : in std_logic_vector (15 downto 0)  := X"0000";
            outp : out std_logic_vector (15 downto 0) := X"0000"
        );
    end component;

    component shifter is
        port (
            inp : in std_logic_vector (15 downto 0)  := X"0000";
            op  : out std_logic_vector (15 downto 0) := X"0000"
        );
    end component;

    component reg is
        port (
            Rdtin : in std_logic_vector (15 downto 0)  := X"0000"; --data input
            Rwe   : in std_logic                       := '0'; --write enable
            Rclk  : in std_logic                       := '0'; --clock
            Rdout : out std_logic_vector (15 downto 0) := X"0000" --data output
        );
    end component;

    component FSM is
        port (
            Fclk          : in std_logic                        := '0'; --Clock
            ram_data_out  : in std_logic_vector(15 downto 0)    := X"0000";
            State         : inout integer                       := 0; --FSM State
            rom_read_adr  : out std_logic_vector(15 downto 0)   := X"0000";
            mul_write_adr : inout std_logic_vector(7 downto 0)  := X"00";
            img_read_adr  : inout std_logic_vector(15 downto 0) := X"0000";
            count         : inout integer                       := 0; --Counter
            level         : inout std_logic                     := '0'; --Level of the network
            result        : out unsigned(3 downto 0)            := X"0"
        );
    end component;

    component control is
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
    end component;

    signal Lrom_data, Lmul_write_adr                                  : std_logic_vector(7 downto 0)  := X"00";
    signal Lrom_read_adr, Limg_read_adr                               : std_logic_vector(15 downto 0) := X"0000";
    signal Lmul_inp1, Lmul_res, Lcomp_out, Lreg_data_out, Lshift_out  : std_logic_vector(15 downto 0) := X"0000";
    signal Lmul_inp2                                                  : std_logic_vector(7 downto 0)  := X"00";
    signal Lram_data_out, Lram_data_in                                : std_logic_vector(15 downto 0) := X"0000";
    signal Lram_adr                                                   : std_logic_vector(7 downto 0)  := X"00";
    signal LState, Lcount                                             : integer                       := 0;
    signal Llevel, LMlen, Lreg_en                                     : std_logic                     := '0';
    signal Lfinal, Lreg4_data_in                                      : std_logic_vector(15 downto 0) := X"0000";
    signal Lreg1_en, Lreg2_en, Lreg3_en, Lreg4_en, Lram_write_en      : std_logic                     := '0';
    signal Lreg1_dataout, Lreg2_dataout, Lreg3_dataout, Lreg4_dataout : std_logic_vector(15 downto 0) := X"0000";
    signal Lresult                                                    : unsigned(3 downto 0)          := X"0";
begin

    fsm_init : fsm port map(
        Fclk          => clk,
        ram_data_out  => Lram_data_out,
        State         => LState,
        rom_read_adr  => Lrom_read_adr,
        mul_write_adr => Lmul_write_adr,
        img_read_adr  => Limg_read_adr,
        count         => Lcount,
        level         => Llevel,
        result        => Lresult
    );

    rom_init : rom port map(
        Madr  => Lrom_read_adr,
        Mre   => '1',
        Mdata => Lrom_data
    );

    Lfinal <= std_logic_vector(signed(Lmul_res) + signed(Lreg3_dataout));

    ctrl_init : control port map(
        clk              => clk,
        level            => Llevel,
        count            => Lcount,
        State            => LState,
        rom_data         => Lrom_data,
        mul_write_adr    => Lmul_write_adr,
        img_read_adr     => Limg_read_adr(7 downto 0),
        final            => Lcomp_out,
        Mlres            => Lmul_res,
        ram_adr          => Lram_adr,
        ram_data_in      => Lram_data_in,
        reg4_data_in     => Lreg4_data_in,
        ram_write_enable => Lram_write_en,
        Mlen             => LMlen,
        reg1_write_en    => Lreg1_en,
        reg2_write_en    => Lreg2_en,
        reg3_write_en    => Lreg3_en,
        reg4_write_en    => Lreg4_en
    );

    ram_init : ram port map(
        Mclk  => clk,
        Madr  => Lram_adr,
        Mdtin => Lram_data_in,
        Mwe   => Lram_write_en,
        Mre   => '1',
        Mout  => Lram_data_out
    );

    reg1 : reg port map(
        Rdtin => Lram_data_out,
        Rwe   => Lreg1_en,
        Rclk  => clk,
        Rdout => Lreg1_dataout
    );

    reg2 : reg port map(
        Rdtin => Lram_data_out,
        Rwe   => Lreg2_en,
        Rclk  => clk,
        Rdout => Lreg2_dataout
    );

    reg3 : reg port map(
        Rdtin => Lram_data_out,
        Rwe   => Lreg3_en,
        Rclk  => clk,
        Rdout => Lreg3_dataout
    );

    reg4 : reg port map(
        Rdtin => Lreg4_data_in,
        Rwe   => Lreg4_en,
        Rclk  => clk,
        Rdout => Lreg4_dataout
    );

    mul_init : MUL port map(
        MlClk => clk,
        Mlen  => LMlen,
        MlFst => Lreg1_dataout,
        MlSnd => Lreg2_dataout,
        MlAdd => Lreg4_dataout,
        MlRes => Lmul_res
    );

    comp_init : comparator port map(
        inp  => Lshift_out,
        outp => Lcomp_out
    );

    shift_init : shifter port map(
        inp => Lfinal,
        op  => Lshift_out
    );

end rtl;
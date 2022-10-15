-------------------------------- ROM ---------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity rom is
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
end rom;

architecture rtl of rom is
    -- Changed IMAGE_SIZE to IMAGE_SIZE-1
    type mem_type is array(0 to (1033 + WEIGHT_SIZE + BIAS_SIZE)) of std_logic_vector((DATA_WIDTH - 1) downto 0);
    --    -- Changed WEIGHT_SIZE to WEIGHT_SIZE-1
    --    type wght_type is array(0 to WEIGHT_SIZE - 1) of std_logic_vector((DATA_WIDTH - 1) downto 0);
    --    -- Changed BIAS_SIZE to BIAS_SIZE-1
    --    type bias_type is array(0 to BIAS_SIZE - 1) of std_logic_vector((DATA_WIDTH - 1) downto 0);
    impure function init_mem(mif_file_name_img, mif_file_name_wb : in string) return mem_type is
        file mif_file_img                                            : text open read_mode is mif_file_name_img;
        file mif_file_wb                                             : text open read_mode is mif_file_name_wb;
        variable mif_line_img                                        : line;
        variable mif_line_wb                                         : line;
        variable temp_bv                                             : bit_vector(DATA_WIDTH - 1 downto 0);
        variable temp_mem                                            : mem_type;
    begin
        for i in 0 to IMAGE_SIZE - 1 loop
            readline(mif_file_img, mif_line_img);
            read(mif_line_img, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        for i in IMAGE_SIZE to 1023 loop
            temp_mem(i) := X"00";
        end loop;
        for i in 1024 to (WEIGHT_SIZE + BIAS_SIZE + 1023) loop
            readline(mif_file_wb, mif_line_wb);
            read(mif_line_wb, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        --        for i in WEIGHT_SIZE to BIAS_SIZE - 1 loop
        --            readline(mif_file_wb, mif_line);
        --            read(mif_line, temp_bv);
        --            temp_mem(i) := to_stdlogicvector(temp_bv);
        --        end loop;
        for i in (1024 + WEIGHT_SIZE + BIAS_SIZE) to (WEIGHT_SIZE + BIAS_SIZE + 1033) loop
            temp_mem(i) := X"00";
        end loop;
        -- temp_mem(1024 + WEIGHT_SIZE + BIAS_SIZE) := X"00";
        return temp_mem;
    end function;

    --   Signal Declarations

    signal memory : mem_type := init_mem(IMAGE_FILE_NAME, WEIGHT_BIAS_FILE_NAME);

begin
    Mdata <= memory(to_integer(unsigned(Madr))) when Mre = '1' else X"00";
end rtl;
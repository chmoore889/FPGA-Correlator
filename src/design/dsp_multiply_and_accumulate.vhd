library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity dsp_multiply_and_accumulate is
    Generic (
        numChannels : integer
    );
    Port ( ChaInSel : in STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
           a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           output : out STD_LOGIC_DARRAY (numChannels - 1  downto 0));
           
    attribute use_dsp : string;
    attribute use_dsp of dsp_multiply_and_accumulate : entity is "yes";
end entity;

architecture Behavioral of dsp_multiply_and_accumulate is
    signal accumArr : STD_LOGIC_DARRAY (numChannels - 1 downto 0) := (others => (others => '0'));

    signal a_signed : SIGNED (a'RANGE);
    signal b_signed : SIGNED (b'RANGE);
begin
    a_signed <= signed(a);
    b_signed <= signed(b);
    
    output <= accumArr;

    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                accumArr <= (others => (others => '0'));
            elsif enable = '1' then
                accumArr(arr_select_to_int(ChaInSel)) <= std_logic_vector(
                    a_signed * b_signed +
                    signed(accumArr(arr_select_to_int(ChaInSel))));
            end if;
        end if;
    end process;
end Behavioral;
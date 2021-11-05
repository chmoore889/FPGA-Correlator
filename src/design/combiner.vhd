library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity combiner is
    Generic (
        numChannels : integer
    );
    Port ( clk : in STD_LOGIC;
           ChaInSel : in STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
           Din : in STD_LOGIC_VECTOR (15 downto 0);
           EODin : in STD_LOGIC;
           NDin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           ChaOutSel : out STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0) := (others => '0');
           Dout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           DRdy : out STD_LOGIC := '0';
           EODout : out STD_LOGIC := '0');
end combiner;

architecture Behavioral of combiner is
    signal DReg : STD_LOGIC_DinARRAY (numChannels - 1 downto 0) := (others => (others => '0'));
    signal NDReg : STD_LOGIC_VECTOR (numChannels - 1 downto 0) := (others => '0');
begin
    buffers : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' OR EODin = '1' then
                DReg <= (others => (others => '0'));
                NDReg <= (others => '0');
            elsif NDin = '1' then
                DReg(arr_select_to_int(ChaInSel)) <= Din;
                NDReg(arr_select_to_int(ChaInSel)) <= NOT NDReg(arr_select_to_int(ChaInSel));
            end if;
        end if;
    end process buffers;
    
    output_pipeline : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' then
                EODout <= '0';
                Dout <= (others => '0');
                DRdy <= '0';
                
                ChaOutSel <= (others => '0'); 
            else
                EODout <= EODin;
                Dout <= std_logic_vector(signed(DReg(arr_select_to_int(ChaInSel))) + signed(Din));
                DRdy <= NDin AND NDReg(arr_select_to_int(ChaInSel));
                
                ChaOutSel <= ChaInSel;
            end if;
        end if;
    end process output_pipeline;
end Behavioral;

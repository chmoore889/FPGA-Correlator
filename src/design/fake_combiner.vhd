library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity fake_combiner is
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
end fake_combiner;

architecture Behavioral of fake_combiner is begin    
    output_pipeline : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' then
                EODout <= '0';
                Dout <= (others => '0');
                DRdy <= '0';
                
                ChaOutSel <= (others => '0'); 
            else
                EODout <= EODin;
                Dout <= Din;
                DRdy <= NDin;
                
                ChaOutSel <= ChaInSel;
            end if;
        end if;
    end process output_pipeline;
end Behavioral;

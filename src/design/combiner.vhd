library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity combiner is
    Port ( clk : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (15 downto 0);
           EODin : in STD_LOGIC;
           NDin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (15 downto 0);
           DRdy : out STD_LOGIC;
           EODout : out STD_LOGIC);
end combiner;

architecture Behavioral of combiner is
    signal Buf1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
begin
    EODout <= EODin;
    Dout <= Buf1;

    buffers : process(clk) begin
        if rising_edge(clk) then
            
        end if;
    end process buffers;
end Behavioral;

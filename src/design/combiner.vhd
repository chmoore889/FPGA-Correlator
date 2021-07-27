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
    signal Buf2 : STD_LOGIC := '0';
begin
    EODout <= EODin;
    Dout <= std_logic_vector(unsigned(Buf1) + unsigned(Din));
    DRdy <= NDin AND Buf2;

    buffers : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' then
                Buf1 <= (others => '0');
                Buf2 <= '0';
            elsif NDin = '1' then
                Buf1 <= Din;
                Buf2 <= NOT Buf2;
            end if;
        end if;
    end process buffers;
end Behavioral;

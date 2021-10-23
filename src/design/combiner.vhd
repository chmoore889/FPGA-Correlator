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
    
    signal DoutReg : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal DRdyReg, EODoutReg : STD_LOGIC := '0';
begin
    EODout <= EODoutReg;
    Dout <= DoutReg;
    DRdy <= DRdyReg;

    buffers : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' OR EODin = '1' then
                Buf1 <= (others => '0');
                Buf2 <= '0';
            elsif NDin = '1' then
                Buf1 <= Din;
                Buf2 <= NOT Buf2;
            end if;
        end if;
    end process buffers;
    
    output_pipeline : process(clk) begin
        if rising_edge(clk) then
            if Reset = '1' then
                EODoutReg <= '0';
                DoutReg <= (others => '0');
                DRdyReg <= '0';
            else
                EODoutReg <= EODin;
                DoutReg <= std_logic_vector(signed(Buf1) + signed(Din));
                DRdyReg <= NDin AND Buf2;
            end if;
        end if;
    end process output_pipeline;
end Behavioral;

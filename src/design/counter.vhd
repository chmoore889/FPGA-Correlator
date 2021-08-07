library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Generic (
        countBitSize : integer := 16
    );
    Port ( enable : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (countBitSize - 1 downto 0));
end counter;

architecture Behavioral of counter is
    signal count_local : UNSIGNED (countBitSize - 1 downto 0) := (others => '0');
begin
    count <= std_logic_vector(count_local);

    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                count_local <= (others => '0');
            elsif enable = '1' then
                count_local <= count_local + 1;
            end if;
        end if;
    end process;
end Behavioral;

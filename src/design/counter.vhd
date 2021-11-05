library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.all;

entity counter is
    Generic (
        maxVal : integer
    );
    Port ( enable : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (channels_to_bits(maxVal) - 1 downto 0));
end counter;

architecture Behavioral of counter is
    signal count_local : UNSIGNED (count'RANGE) := (others => '0');
begin
    count <= std_logic_vector(count_local);

    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                count_local <= (others => '0');
            elsif enable = '1' then
                if count_local = maxVal then
                    count_local <= (others => '0');
                else
                    count_local <= count_local + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
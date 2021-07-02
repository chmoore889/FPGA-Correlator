library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Port ( trigger : in STD_LOGIC; --Output `count` increments by 1 on the rising edge of this trigger
           reset : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (15 downto 0));
end counter;

architecture Behavioral of counter is
    signal count_local : UNSIGNED (15 downto 0) := (others => '0');
begin
    count <= std_logic_vector(count_local);

    process (trigger, reset) begin
        if reset = '1' then
            count_local <= (others => '0');
        elsif rising_edge(trigger) then
            count_local <= count_local + 1;
        end if;
    end process;
end Behavioral;

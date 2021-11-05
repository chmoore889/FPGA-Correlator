library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity mac_counter is
    Generic (
        numCha : integer
    );
    Port ( enable : in STD_LOGIC;
           chaNum : in STD_LOGIC_VECTOR (channels_to_bits(numCha) - 1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           counts : out STD_LOGIC_NARRAY (numCha - 1 downto 0));
end mac_counter;

architecture Behavioral of mac_counter is
    type INTERNAL_COUNT_ARR is array (counts'RANGE) of UNSIGNED (counts(0)'RANGE);
    
    function internal_to_narray(
        arr : in INTERNAL_COUNT_ARR)
    return STD_LOGIC_NARRAY is
        variable toReturn : STD_LOGIC_NARRAY (arr'RANGE);
    begin
        for I in arr'RANGE loop
            toReturn(I) := std_logic_vector(arr(I));
        end loop;
        return toReturn;
    end;

    signal count_local : INTERNAL_COUNT_ARR := (others => (others => '0'));
begin
    counts <= internal_to_narray(count_local);

    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                count_local <= (others => (others => '0'));
            elsif enable = '1' then
                count_local(arr_select_to_int(chaNum)) <= count_local(arr_select_to_int(chaNum)) + 1;
            end if;
        end if;
    end process;
end Behavioral;

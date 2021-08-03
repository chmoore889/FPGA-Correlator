library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity combiner_testbench is
end combiner_testbench;

architecture Behavioral of combiner_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 10;
    signal clock : std_logic := '0';

    component combiner is
        Port ( clk : in STD_LOGIC;
               Din : in STD_LOGIC_VECTOR (15 downto 0);
               EODin : in STD_LOGIC;
               NDin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (15 downto 0);
               DRdy : out STD_LOGIC;
               EODout : out STD_LOGIC);
    end component;
    
    signal Din, Dlatch, Dout : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal EODin, EODlatch, NDin, NDlatch, Reset, Resetlatch, DRdy, EODout : STD_LOGIC := '0';
    
    type INT_ARRAY is array (integer range <>) of integer;
    constant dummyData : INT_ARRAY := (15, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
begin
    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;
    
    latches : process(clock) begin
        if rising_edge(clock) then
            Dlatch <= Din;
            EODlatch <= EODin;
            NDlatch <= NDin;
            Resetlatch <= Reset;
        end if;
    end process latches;

    to_test : combiner
    port map(
        clk => clock,
        Din => Dlatch,
        EODin => EODlatch,
        NDin => NDlatch,
        Reset => Resetlatch,
        Dout => Dout,
        DRdy => DRdy,
        EODout => EODout
    );
    
    test_in : process begin
        Reset <= '1';
        wait for CLOCK_PERIOD;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
        for X in 1 to 2 loop
            for I in dummyData'RANGE loop
                Din <= std_logic_vector(to_unsigned(dummyData(I), Din'LENGTH));
                NDin <= '1';
                if I = dummyData'RIGHT then
                    EODin <= '1';
                end if;
                wait for CLOCK_PERIOD;
                
                NDin <= '0';
                if I = dummyData'RIGHT then
                    EODin <= '0';
                else
                    wait for DATA_IN_PERIOD;
                end if;
            end loop;
            wait for DATA_IN_PERIOD;
        end loop;
        
        wait for CLOCK_PERIOD;
        finish;
    end process;
end Behavioral;

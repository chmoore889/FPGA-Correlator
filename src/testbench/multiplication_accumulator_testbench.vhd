library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity multiplication_accumulator_testbench is
end multiplication_accumulator_testbench;

architecture Behavioral of multiplication_accumulator_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 20;
    signal clock : std_logic := '0';

    component multiplication_accumulator is
        Port ( Clk : in STD_LOGIC;
               Ain : in STD_LOGIC_VECTOR (15 downto 0);
               Bin : in STD_LOGIC_VECTOR (15 downto 0);
               ND : in STD_LOGIC;
               EODin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Din : in STD_LOGIC_VECTOR (31 downto 0);
               Nin : in STD_LOGIC_VECTOR (15 downto 0);
               DinRdy : in STD_LOGIC;
               Aout : out STD_LOGIC_VECTOR (15 downto 0);
               Bout : out STD_LOGIC_VECTOR (15 downto 0);
               BRdy : out STD_LOGIC;
               EODout : out STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (31 downto 0);
               Nout : out STD_LOGIC_VECTOR (15 downto 0);
               DoutRdy : out STD_LOGIC);
    end component;
    
    signal Ain, Bin, Nin : STD_LOGIC_VECTOR (15 downto 0);
    signal ND, EODin, Reset, DinRdy : STD_LOGIC;
    signal Din : STD_LOGIC_VECTOR (31 downto 0);
begin
    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;
    
    to_test : multiplication_accumulator
    port map (
        Clk => clock,
        Ain => Ain,
        Bin => Bin,
        Nin => Nin,
        Din => Din,
        ND => ND,
        EODin => EODin,
        Reset => Reset,
        DinRdy => DinRdy
    );

    test : process
    begin
        Ain <= std_logic_vector(to_unsigned(5, Ain'LENGTH));
        Bin <= std_logic_vector(to_unsigned(10, Bin'LENGTH));
        wait for 1200ns;
        
        finish;
    end process test;
end Behavioral;

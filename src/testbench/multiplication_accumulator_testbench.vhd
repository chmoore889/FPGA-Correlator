library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity multiplication_accumulator_testbench is
end multiplication_accumulator_testbench;

architecture Behavioral of multiplication_accumulator_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 10;
    signal clock : std_logic := '0';

    component multiplication_accumulator is
        Port ( Clk : in STD_LOGIC;
               Ain : in STD_LOGIC_VECTOR (15 downto 0);
               Bin : in STD_LOGIC_VECTOR (15 downto 0);
               NDin : in STD_LOGIC;
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
    
    signal Ain, Bin, Nin : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal NDin, EODin, Reset, DinRdy : STD_LOGIC := '0';
    signal Din : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
    signal Dout : STD_LOGIC_VECTOR (31 downto 0);
    signal Aout, Bout, Nout : STD_LOGIC_VECTOR (15 downto 0);
    signal BRdy, DoutRdy, EODout : STD_LOGIC;
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
        NDin => NDin,
        EODin => EODin,
        Reset => Reset,
        DinRdy => DinRdy,
        Dout => Dout,
        Nout => Nout,
        DoutRdy => DoutRdy,
        Aout => Aout,
        Bout => Bout,
        BRdy => BRdy,
        EODout => EODout
    );

    test : process
    begin
        wait for CLOCK_PERIOD;
    
        Ain <= std_logic_vector(to_unsigned(5, Ain'LENGTH));
        Bin <= std_logic_vector(to_unsigned(5, Bin'LENGTH));
        NDin <= '1';
        wait for CLOCK_PERIOD;
        NDin <= '0';
        wait for DATA_IN_PERIOD - CLOCK_PERIOD;
        
        Ain <= std_logic_vector(to_unsigned(6, Ain'LENGTH));
        Bin <= std_logic_vector(to_unsigned(6, Bin'LENGTH));
        NDin <= '1';
        wait for CLOCK_PERIOD;
        NDin <= '0';
        wait for DATA_IN_PERIOD - CLOCK_PERIOD;
        
        Ain <= std_logic_vector(to_unsigned(7, Ain'LENGTH));
        Bin <= std_logic_vector(to_unsigned(7, Bin'LENGTH));
        NDin <= '1';
        EODin <= '1';
        wait for CLOCK_PERIOD;
        NDin <= '0';
        EODin <= '0';
        wait for DATA_IN_PERIOD - CLOCK_PERIOD;
        
        wait for CLOCK_PERIOD * 5;
        
        finish;
    end process test;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity correlator_combiner_testbench is
end correlator_combiner_testbench;

architecture Behavioral of correlator_combiner_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 10;
    signal clock : std_logic := '0';
    
    constant num_runs : integer := 2;
    
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
    
    component correlator is
        Generic (
            numDelays : integer := 8
        );
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
    
    procedure simulateData (dataInt : in integer;
                            isEnd, delayEnd : in boolean := false;
                            signal dataCtrl : out STD_LOGIC_VECTOR (15 downto 0);
                            signal NDCtrl, EODCtrl : out STD_LOGIC) is
    begin
        dataCtrl <= std_logic_vector(to_signed(dataInt, dataCtrl'LENGTH));
        NDCtrl <= '1';
        if isEnd AND NOT delayEnd then
            EODCtrl <= '1';
        end if;
        wait for CLOCK_PERIOD;
        
        NDCtrl <= '0';
        if isEnd AND delayEnd then
            wait for DATA_IN_PERIOD - CLOCK_PERIOD;
            EODCtrl <= '1';
            wait for CLOCK_PERIOD;
            EODCtrl <= '0';
        elsif isEnd then
            EODCtrl <= '0';
        else
            wait for DATA_IN_PERIOD - CLOCK_PERIOD;
        end if;
    end simulateData;
    
    signal data, dataLatch, Aout, Bout : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal NDin, NDLatch, EODin, EODLatch, Reset : STD_LOGIC := '0';
    
    signal Dout, Dout2 : STD_LOGIC_VECTOR (31 downto 0);
    signal Nout, Nout2, combinerDout1, combinerDout2 : STD_LOGIC_VECTOR (15 downto 0);
    signal DoutRdy, DoutRdy2, BRdy, EODout, combinerDRdy1, combinerDRdy2, combinerEODout1, combinerEODout2, combinedDRdy, combinedEODout : STD_LOGIC;
    
    type INT_ARRAY is array (integer range <>) of integer;
    constant dummyData : INT_ARRAY(1 to 24) := (15, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24);
begin
    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;
    
    latches : process (clock) begin
        if rising_edge(clock) then
            dataLatch <= data;
            EODLatch <= EODin;
            NDLatch <= NDin;
        end if;
    end process latches;

    correlator_to_test : correlator
    port map (
        Clk => clock,
        Ain => dataLatch,
        Bin => dataLatch,
        NDin => NDLatch,
        EODin => EODLatch,
        Reset => Reset,
        Dout => Dout,
        Nout => Nout,
        DoutRdy => DoutRdy,
        Din => Dout2,
        Nin => Nout2,
        DinRdy => DoutRdy2,
        Aout => Aout,
        Bout => Bout,
        BRdy => BRdy,
        EODout => EODout
    );
    
    combiner_to_test_1 : combiner
    port map(
        clk => clock,
        Din => Aout,
        EODin => EODout,
        NDin => BRdy,
        Reset => Reset,
        Dout => combinerDout1,
        DRdy => combinerDRdy1,
        EODout => combinerEODout1
    );
    
    combiner_to_test_2 : combiner
    port map(
        clk => clock,
        Din => Bout,
        EODin => EODout,
        NDin => BRdy,
        Reset => Reset,
        Dout => combinerDout2,
        DRdy => combinerDRdy2,
        EODout => combinerEODout2
    );
    
    combinedDRdy <= combinerDRdy1 AND combinerDRdy2;
    combinedEODout <= combinerEODout1 AND combinerEODout2; 
    correlator_to_test_2 : correlator
    port map (
        Clk => clock,
        Ain => combinerDout1,
        Bin => combinerDout2,
        NDin => combinedDRdy,
        EODin => combinedEODout,
        Reset => Reset,
        Dout => Dout2,
        Nout => Nout2,
        DoutRdy => DoutRdy2,
        Din => (others => '0'),
        Nin => (others => '0'),
        DinRdy => '0'
--        Aout => Aout,
--        Bout => Bout,
--        BRdy => BRdy,
--        EODout => EODout
    );
    
    test_in : process
        variable isEnd : boolean := false;
    begin
        Reset <= '1';
        wait for CLOCK_PERIOD;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
        isEnd := false;
        for I in dummyData'RANGE loop
            if I = dummyData'RIGHT then
                isEnd := true;
            end if;
        
            simulateData(
                dataInt => dummyData(I),
                isEnd => isEnd,
                dataCtrl => data,
                NDCtrl => NDin,
                EODCtrl => EODin
            );
        end loop;
        
        wait for 18 * CLOCK_PERIOD;
        finish;
    end process test_in;
end Behavioral;

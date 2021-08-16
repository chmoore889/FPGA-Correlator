library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity correlator_testbench is
end correlator_testbench;

architecture Behavioral of correlator_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 10;
    signal clock : std_logic := '0';

    constant num_delays : integer := 8;
    constant num_runs : integer := 1;

    component correlator is
        Generic (
            numDelays : integer;
            additionalLatency : integer := 5
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
        dataCtrl <= std_logic_vector(to_unsigned(dataInt, dataCtrl'LENGTH));
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
    
    signal Dout : STD_LOGIC_VECTOR (31 downto 0);
    signal Nout : STD_LOGIC_VECTOR (15 downto 0);
    signal DoutRdy, BRdy, EODout : STD_LOGIC;
    
    type INT_ARRAY is array (integer range <>) of integer;
    constant dummyData : INT_ARRAY(1 to 10) := (15, 2, 3, 4, 5, 6, 7, 8, 9, 10);
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
    
    to_test : correlator
    generic map(
        numDelays => num_delays
    )
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
        Din => (others => '0'),
        Nin => (others => '0'),
        DinRdy => '0',
        Aout => Aout,
        Bout => Bout,
        BRdy => BRdy,
        EODout => EODout
    );
    
    test_in : process
        variable isEnd : boolean := false;
    begin
        Reset <= '1';
        wait for CLOCK_PERIOD;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
        for X in 1 to num_runs loop
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
            
            wait for CLOCK_PERIOD * 20;
        end loop;
        
        --Make sure reset signal does its job
        isEnd := false;
        for I in dummyData'RANGE loop
            simulateData(
                dataInt => dummyData(I),
                isEnd => isEnd,
                dataCtrl => data,
                NDCtrl => NDin,
                EODCtrl => EODin
            );
        end loop;
        
        wait for CLOCK_PERIOD * 20;
    
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
                delayEnd => isEnd,
                dataCtrl => data,
                NDCtrl => NDin,
                EODCtrl => EODin
            );
        end loop;
        
        wait;
    end process test_in;
    
    --Verify that the outputed data is correct
    verify_test : process
        variable accum : integer := 0;
    begin
        --+1 for Reset test
        for X in 1 to num_runs + 1 loop
            for I in 0 to num_delays-1 loop        
                wait until rising_edge(clock) AND DoutRdy = '1';
                
                accum := 0;
                for Y in dummyData'LEFT to dummyData'RIGHT - I loop
                    accum := accum + dummyData(Y) * dummyData(Y+I);
                end loop;
                
                assert accum = to_integer(unsigned(Dout)) report "DOut is incorrect - expected: "
                & integer'image(accum)
                & " actual: "
                & integer'image(to_integer(unsigned(Dout)));
                
                assert (dummyData'RIGHT - I) = to_integer(unsigned(NOut)) report "NOut is incorrect - expected: "
                & integer'image(dummyData'RIGHT - I)
                & " actual: "
                & integer'image(to_integer(unsigned(NOut)));
            end loop;
        end loop;
        
        wait for CLOCK_PERIOD;
        
        finish;
    end process verify_test;
end Behavioral;
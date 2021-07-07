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

    component correlator is
        Generic (
            numDelays : integer
        );
        Port ( clk : in STD_LOGIC;
               data : in STD_LOGIC_VECTOR (15 downto 0);
               NDin : in STD_LOGIC;
               EODin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (31 downto 0);
               DoutRdy : out STD_LOGIC;
               Nout : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    procedure simulateData (dataInt : in integer;
                            isEnd : in boolean;
                            signal dataCtrl : out STD_LOGIC_VECTOR (15 downto 0);
                            signal NDCtrl, EODCtrl : out STD_LOGIC) is
    begin
        dataCtrl <= std_logic_vector(to_unsigned(dataInt, dataCtrl'LENGTH));
        NDCtrl <= '1';
        if isEnd then
            EODCtrl <= '1';
        end if;
        wait for CLOCK_PERIOD;
        
        dataCtrl <= (others => '0');
        NDCtrl <= '0';
        if isEnd then
            EODCtrl <= '0';
        end if;
        wait for DATA_IN_PERIOD - CLOCK_PERIOD;
    end simulateData;
    
    signal data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal NDin, EODin, Reset : STD_LOGIC := '0';
    
    signal Dout : STD_LOGIC_VECTOR (31 downto 0);
    signal Nout : STD_LOGIC_VECTOR (15 downto 0);
    signal DoutRdy : STD_LOGIC;
begin
    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;
    
    to_test : correlator
    generic map(
        numDelays => 5
    )
    port map (
        Clk => clock,
        data => data,
        NDin => NDin,
        EODin => EODin,
        Reset => Reset,
        Dout => Dout,
        Nout => Nout,
        DoutRdy => DoutRdy
    );
    
    test : process
    begin
        wait for CLOCK_PERIOD;
    
        simulateData(
            dataInt => 5,
            isEnd => false,
            dataCtrl => data,
            NDCtrl => NDin,
            EODCtrl => EODin
        );
        
        simulateData(
            dataInt => 6,
            isEnd => false,
            dataCtrl => data,
            NDCtrl => NDin,
            EODCtrl => EODin
        );
        
        simulateData(
            dataInt => 7,
            isEnd => false,
            dataCtrl => data,
            NDCtrl => NDin,
            EODCtrl => EODin
        );
        
        simulateData(
            dataInt => 8,
            isEnd => false,
            dataCtrl => data,
            NDCtrl => NDin,
            EODCtrl => EODin
        );
        
        simulateData(
            dataInt => 9,
            isEnd => true,
            dataCtrl => data,
            NDCtrl => NDin,
            EODCtrl => EODin
        );
        
        wait for CLOCK_PERIOD * 5;
        
        finish;
    end process test;
end Behavioral;

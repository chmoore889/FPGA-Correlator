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

    constant num_delays : integer := 5;

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
        else
            wait for DATA_IN_PERIOD - CLOCK_PERIOD;
        end if;
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
        numDelays => num_delays
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
    
    test_in : process
        variable isEnd : boolean := false;
    begin
        --Make sure reset signal does its job
        for I in 1 to 10 loop
            simulateData(
                dataInt => I,
                isEnd => isEnd,
                dataCtrl => data,
                NDCtrl => NDin,
                EODCtrl => EODin
            );
        end loop;
    
        Reset <= '1';
        wait for CLOCK_PERIOD;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
        --Procede to actual test of correct correlator results
        for I in 1 to 10 loop
            if I = 10 then
                isEnd := true;
            end if;
        
            simulateData(
                dataInt => I,
                isEnd => isEnd,
                dataCtrl => data,
                NDCtrl => NDin,
                EODCtrl => EODin
            );
        end loop;
        
        wait;
    end process test_in;
    
    verify_test : process
        type INT_ARRAY is array (integer range <>) of integer;
        variable data : INT_ARRAY(1 to 10) := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        variable accum : integer := 0;
    begin
        for I in 0 to num_delays-1 loop        
            wait until rising_edge(DoutRdy);
            
            accum := 0;
            for X in data'LEFT to data'RIGHT - I loop
                accum := accum + data(X) * data(X+I);
            end loop;
            
            assert accum = to_integer(unsigned(Dout)) report "DOut is incorrect - expected: "
            & integer'image(accum)
            & " actual: "
            & integer'image(to_integer(unsigned(Dout)));
            
            assert (10 - I) = to_integer(unsigned(NOut)) report "NOut is incorrect - expected: "
            & integer'image(10 - I)
            & " actual: "
            & integer'image(to_integer(unsigned(NOut)));
            
            wait until falling_edge(DoutRdy);
        end loop;
        
        wait for CLOCK_PERIOD;
        
        finish;
    end process verify_test;
end Behavioral;

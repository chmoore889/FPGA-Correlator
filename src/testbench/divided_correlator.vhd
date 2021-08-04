library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity divided_correlator is
end divided_correlator;

architecture Behavioral of divided_correlator is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 5;
    signal clock : std_logic := '0';
    
    component correlator is
        Generic (
            numDelays : integer
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
    
    COMPONENT uint32_to_single
      PORT (
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT single_divider
      PORT (
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid : IN STD_LOGIC;
        s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
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
    
    signal Dout, DoutFloat, paddedNout, NoutFloat, dividedResult : STD_LOGIC_VECTOR (31 downto 0);
    signal Nout : STD_LOGIC_VECTOR (15 downto 0);
    signal DoutRdy, DoutFloatRdy, NoutFloatRdy, dividedResultRdy, BRdy, EODout : STD_LOGIC;
    
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
        numDelays => 8
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
    
    dout_to_single : uint32_to_single
    PORT MAP (
      s_axis_a_tvalid => DoutRdy,
      s_axis_a_tdata => Dout,
      m_axis_result_tvalid => DoutFloatRdy,
      m_axis_result_tdata => DoutFloat
    );
    
    paddedNout <= (paddedNout'HIGH downto Nout'HIGH + 1 => '0') & Nout;
    nout_to_single : uint32_to_single
    PORT MAP (
      s_axis_a_tvalid => DoutRdy,
      s_axis_a_tdata => paddedNout,
      m_axis_result_tvalid => NoutFloatRdy,
      m_axis_result_tdata => NoutFloat
    );
    
    divider : single_divider
    PORT MAP (
      s_axis_a_tvalid => DoutFloatRdy,
      s_axis_a_tdata => DoutFloat,
      s_axis_b_tvalid => NoutFloatRdy,
      s_axis_b_tdata => NoutFloat,
      m_axis_result_tvalid => dividedResultRdy,
      m_axis_result_tdata => dividedResult
    );
    
    test_in : process
        variable isEnd : boolean := false;
    begin
        Reset <= '1';
        wait for CLOCK_PERIOD;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
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
        
        wait until falling_edge(DoutRdy);
        
        wait for CLOCK_PERIOD;
        
        finish;
    end process test_in;
end Behavioral;

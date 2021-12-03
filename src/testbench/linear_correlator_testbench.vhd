library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;
use std.env.finish;

entity linear_correlator_testbench is
end linear_correlator_testbench;

architecture Behavioral of linear_correlator_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    constant DATA_IN_PERIOD : time := CLOCK_PERIOD * 2;
    constant numChannels : integer := 2;
    
    signal clock : std_logic := '0';

    component linear_correlator
        Generic (
            numChannels : integer
        );
        Port ( Clk : in STD_LOGIC;
               ChaInSel : in STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
               Ain : in STD_LOGIC_VECTOR (15 downto 0);
               Bin : in STD_LOGIC_VECTOR (15 downto 0);
               NDin : in STD_LOGIC;
               EODin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); --Normalized single-precision value.
               DoutRdy : out STD_LOGIC := '0');
    end component;
    
    signal data, dataLatch : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal NDin, NDLatch, EODin, EODLatch, Reset : STD_LOGIC := '0';
    
    signal Dout : STD_LOGIC_VECTOR (31 downto 0);
    signal DoutRdy : STD_LOGIC;
    signal chaSel, chaSelLatch : STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0) := (others => '0');
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
            chaSelLatch <= chaSel;
        end if;
    end process latches;
    
    to_test : linear_correlator
    generic map (
        numChannels => numChannels
    )
    port map (
        Clk => clock,
        ChaInSel => chaSelLatch,
        Ain => dataLatch,
        Bin => dataLatch,
        NDin => NDLatch,
        EODin => EODLatch,
        Reset => Reset,
        Dout => Dout,
        DoutRdy => DoutRdy
    );
    
    test_in : process
        variable isEnd : boolean := false;
    begin
        wait for 110 ns;
    
        Reset <= '1';
        wait for CLOCK_PERIOD * 2;
        Reset <= '0';
        wait for CLOCK_PERIOD;
        
        NDin <= '1';
        for I in 1 to 4096 loop
            if I = 4096 then
                isEnd := true;
            end if;
            
            chaSel <= std_logic_vector(to_unsigned(0, chaSel'LENGTH));
            data <= std_logic_vector(to_signed(1, data'LENGTH));
            wait for CLOCK_PERIOD;

            
            chaSel <= std_logic_vector(to_unsigned(1, chaSel'LENGTH));
            data <= std_logic_vector(to_signed(2, data'LENGTH));
            if isEnd then
                EODin <= '1';
            end if;
            wait for CLOCK_PERIOD;
            
            if isEnd then
                EODin <= '0';
                NDin <= '0';
                wait for CLOCK_PERIOD;
            end if;
        end loop;
        
        wait until falling_edge(DoutRdy);
        wait for CLOCK_PERIOD;
    
        finish;
    end process test_in;
end Behavioral;

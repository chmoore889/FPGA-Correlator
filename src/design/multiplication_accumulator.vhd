library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity multiplication_accumulator is
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
           Din : in STD_LOGIC_VECTOR (31 downto 0);
           Nin : in STD_LOGIC_VECTOR (15 downto 0);
           DinRdy : in STD_LOGIC;
           ChaOutSel : out STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
           Aout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           Bout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           BRdy : out STD_LOGIC := '0';
           EODout : out STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           Nout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           DoutRdy : out STD_LOGIC := '0');
end multiplication_accumulator;

architecture Behavioral of multiplication_accumulator is
    signal EODDelay : STD_LOGIC := '0';
    
    signal multiplier_out : STD_LOGIC_DARRAY (numChannels - 1 downto 0);    
    signal counter_out : STD_LOGIC_NARRAY (numChannels - 1 downto 0);
begin
    Aout <= Ain;
    EODout <= EODin;
    ChaOutSel <= ChaInSel;
    
    mult_mux_selects : block
        signal BBufArr : STD_LOGIC_DinARRAY (numChannels - 1 downto 0) := (others => (others => '0'));
        signal multiple_accum_enable : STD_LOGIC;
        
        component dsp_multiply_and_accumulate is
            Generic (
                numChannels : integer
            );
            Port ( ChaInSel : in STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
                   a : in STD_LOGIC_VECTOR (15 downto 0);
                   b : in STD_LOGIC_VECTOR (15 downto 0);
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   enable : in STD_LOGIC;
                   output : out STD_LOGIC_DARRAY (0 to numChannels - 1));
        end component;
        
        signal dsp_reset : STD_LOGIC;
    begin
        dsp_reset <= Reset OR EODDelay;
        multiple_accum_enable <= NOT Reset AND NDin;
    
        Bout <= BBufArr(arr_select_to_int(ChaInSel));
        process (Clk) begin
            if rising_edge(Clk) then
                if dsp_reset = '1' then
                    BBufArr <= (others => (others => '0'));
                elsif NDin = '1' then
                    BBufArr(arr_select_to_int(ChaInSel)) <= Bin;
                end if;
            end if;
        end process;
        
        multiplier : dsp_multiply_and_accumulate
        generic map (
            numChannels => numChannels
        )
        port map (
            ChaInSel => ChaInSel,
            a => Ain,
            b => Bin,
            clk => Clk,
            reset => dsp_reset,
            enable => multiple_accum_enable,
            output => multiplier_out
        );
    end block mult_mux_selects;
    
    b_rdy : block
        signal firstDataDoneArr : STD_LOGIC_VECTOR (numChannels - 1 downto 0) := (others => '0');
        signal new_data_reset : STD_LOGIC := '0';
    begin
        new_data_reset <= Reset OR EODDelay;
        
        BRdy <= NDin AND firstDataDoneArr(arr_select_to_int(ChaInSel));
        
        b_out : process (Clk) begin
            if rising_edge(Clk) then
                EODDelay <= EODin;
                                
                if new_data_reset = '1' then
                    firstDataDoneArr <= (others => '0');
                elsif NDin = '1' then
                    firstDataDoneArr(arr_select_to_int(ChaInSel)) <= '1';
                end if;
            end if;
        end process b_out;
    end block b_rdy;
    
    counters : block
        component mac_counter is
            Generic (
                numCha : integer
            );
            Port ( enable : in STD_LOGIC;
                   chaNum : in STD_LOGIC_VECTOR (channels_to_bits(numCha) - 1 downto 0);
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   counts : out STD_LOGIC_NARRAY (numCha - 1 downto 0));
        end component;
        
        signal counter_reset : STD_LOGIC;
    begin
        counter_reset <= Reset OR EODDelay;
        
        count : mac_counter
        generic map (
            numCha => numChannels
        )
        port map (
            enable => NDin,
            chaNum => ChaInSel,
            clk => Clk,
            reset => counter_reset,
            counts => counter_out
        );
    end block counters;
    
    data_handling : block
        signal DoutArr : STD_LOGIC_DARRAY (numChannels - 1 downto 0) := (others => (others => '0'));
        signal DoutRdyArr : STD_LOGIC_VECTOR (numChannels - 1 downto 0) := (others => '0');
        signal NoutArr : STD_LOGIC_NARRAY (numChannels - 1 downto 0) := (others => (others => '0'));
    begin
        Dout <= DoutArr(0);
        DoutRdy <= DoutRdyArr(0);
        Nout <= NoutArr(0);
    
        process (Clk) begin
            if rising_edge(Clk) then
                if Reset = '1' then
                    DoutArr <= (others => (others => '0'));
                    DoutRdyArr <= (others => '0');
                    NoutArr <= (others => (others => '0'));
                elsif EODDelay = '1' then
                    DoutArr <= multiplier_out;
                    DoutRdyArr <= (others => '1');
                    NoutArr <= counter_out;
                else
                    DoutArr(DoutArr'HIGH - 1 downto 0) <= DoutArr(DoutArr'HIGH downto 1);
                    DoutArr(DoutArr'HIGH) <= Din;
                    
                    DoutRdyArr(DoutRdyArr'HIGH - 1 downto 0) <= DoutRdyArr(DoutRdyArr'HIGH downto 1);
                    DoutRdyArr(DoutRdyArr'HIGH) <= DinRdy;
                    
                    NoutArr(NoutArr'HIGH - 1 downto 0) <= NoutArr(NoutArr'HIGH downto 1);
                    NoutArr(NoutArr'HIGH) <= Nin;
                end if;
            end if;
        end process;
    end block data_handling;
end Behavioral;

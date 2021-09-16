library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplication_accumulator is
    Generic (
        accumRegSize : integer := 47 --Bit width of registers used for accumulation. Max value of 47.
    );
    Port ( Clk : in STD_LOGIC;
           Ain : in STD_LOGIC_VECTOR (15 downto 0);
           Bin : in STD_LOGIC_VECTOR (15 downto 0);
           NDin : in STD_LOGIC;
           EODin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (accumRegSize - 1 downto 0);
           Nin : in STD_LOGIC_VECTOR (15 downto 0);
           DinRdy : in STD_LOGIC;
           Aout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           Bout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           BRdy : out STD_LOGIC := '0';
           EODout : out STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (accumRegSize - 1 downto 0) := (others => '0');
           Nout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           DoutRdy : out STD_LOGIC := '0');
end multiplication_accumulator;

architecture Behavioral of multiplication_accumulator is
    signal EODDelay : STD_LOGIC := '0';
    
    signal multiplier_out : STD_LOGIC_VECTOR (Dout'RANGE) := (others => '0');
    signal counter_out : STD_LOGIC_VECTOR (Nout'RANGE) := (others => '0');
begin
    Aout <= Ain;
    EODout <= EODin;
    
    mult_mux_selects : block
        signal Buf1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
        signal mux_selector : STD_LOGIC;
        
        component dsp_multiply_and_accumulate is
            Generic (
                accumRegSize : integer := 47
            );
            Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
                   b : in STD_LOGIC_VECTOR (15 downto 0);
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   M1_select : in STD_LOGIC;
                   output : out STD_LOGIC_VECTOR (accumRegSize - 1 downto 0));
        end component;
        
        signal dsp_reset : STD_LOGIC;
    begin
        dsp_reset <= Reset OR EODDelay;
        mux_selector <= NOT Reset AND NDin;
    
        Bout <= Buf1;
        process (Clk) begin
            if rising_edge(Clk) then
                if dsp_reset = '1' then
                    Buf1 <= (others => '0');
                elsif NDin = '1' then
                    Buf1 <= Bin;
                end if;
            end if;
        end process;
        
        multiplier : dsp_multiply_and_accumulate
        port map (
            a => Ain,
            b => Bin,
            clk => Clk,
            reset => dsp_reset,
            M1_select => mux_selector,
            output => multiplier_out
        );
    end block mult_mux_selects;
    
    b_rdy : block
        signal firstDataDone, new_data_reset : STD_LOGIC := '0';
    begin
        new_data_reset <= Reset OR EODDelay;
        
        BRdy <= NDin AND firstDataDone;
        
        b_out : process (Clk) begin
            if rising_edge(Clk) then
                EODDelay <= EODin;
                                
                if new_data_reset = '1' then
                    firstDataDone <= '0';
                elsif NDin = '1' then
                    firstDataDone <= '1';
                end if;
            end if;
        end process b_out;
    end block b_rdy;
    
    counter : block
        component counter is
            Port ( enable : in STD_LOGIC;
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   count : out STD_LOGIC_VECTOR (15 downto 0));
        end component;
        
        signal counter_reset : STD_LOGIC;
    begin
        counter_reset <= Reset OR EODDelay;
    
        count : counter
        port map(
            enable => NDin,
            clk => Clk,
            reset => counter_reset,
            count => counter_out
        );
    end block counter;
    
    data_handling : block
    begin
        process (Clk) begin
            if rising_edge(Clk) then
                if EODDelay = '1' then
                    Dout <= multiplier_out;
                    DoutRdy <= '1';
                    Nout <= counter_out;
                else
                    Dout <= Din;
                    DoutRdy <= DinRdy;
                    Nout <= Nin;
                end if;
            end if;
        end process;
    end block data_handling;
end Behavioral;

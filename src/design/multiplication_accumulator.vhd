library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplication_accumulator is
    Generic (
        useCascade : boolean
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
end multiplication_accumulator;

architecture Behavioral of multiplication_accumulator is
    signal N : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal ND, EOD : STD_LOGIC := '0';
    
    signal NDout, EODDelay, DRdy : STD_LOGIC := '0';
    
    signal multiplier_out, D : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal counter_out : STD_LOGIC_VECTOR (15 downto 0);
begin
    BRdy <= NDout;
    EODout <= EOD;
    
    Dout <= D;
    DoutRdy <= DRdy;
    Nout <= N;
    
    mult_mux_selects : block
        component dsp_multiply_and_accumulate is
            Generic (
                useCascade : boolean
            );
            Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
                   b : in STD_LOGIC_VECTOR (15 downto 0);
                   aout : out STD_LOGIC_VECTOR (15 downto 0);
                   bout : out STD_LOGIC_VECTOR (15 downto 0);
                   b2enable : in STD_LOGIC;
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   output : out STD_LOGIC_VECTOR (31 downto 0));
        end component;
        
        signal dsp_reset : STD_LOGIC;
    begin
        dsp_reset <= Reset OR EODDelay;
        
        multiplier : dsp_multiply_and_accumulate
        generic map (
            useCascade => useCascade
        )
        port map (
            a => Ain,
            b => Bin,
            aout => Aout,
            bout => Bout,
            b2enable => ND,
            clk => Clk,
            reset => dsp_reset,
            output => multiplier_out
        );
    end block mult_mux_selects;

    inputs : process (Clk) begin
        if rising_edge(Clk) then
            ND <= NDin;
            EOD <= EODin;
            
            EODDelay <= EOD;
        end if;
    end process inputs;
    
    cascade_manage : block
        signal firstDataDone, new_data_reset : STD_LOGIC := '0';
    begin
        new_data_reset <= Reset OR EODDelay;
    
        new_data_cascade : process (Clk) begin
            if rising_edge(Clk) then
                if firstDataDone = '1' then
                    NDout <= NDin;
                end if;
                
                if new_data_reset = '1' then
                    firstDataDone <= '0';
                elsif NDin = '1' then
                    firstDataDone <= '1';
                end if;
            end if;
        end process new_data_cascade;
    end block cascade_manage;
    
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
            enable => ND,
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
                    D <= multiplier_out;
                    DRdy <= '1';
                    N <= counter_out;
                else
                    D <= Din;
                    DRdy <= DinRdy;
                    N <= Nin;
                end if;
            end if;
        end process;
    end block data_handling;
end Behavioral;

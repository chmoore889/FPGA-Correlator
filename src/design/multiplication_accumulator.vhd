library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity multiplication_accumulator is
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
    signal A, B : STD_LOGIC_VECTOR (15 downto 0);
    signal ND, EOD : STD_LOGIC;
    
    signal L1, EODDelay : STD_LOGIC;
    
    signal multiplier_out : STD_LOGIC_VECTOR (31 downto 0);
    signal counter_out : STD_LOGIC_VECTOR (15 downto 0);
begin
    Aout <= A;
    EODout <= EOD;
    
    mult_mux_selects : block
        signal M1, Buf1 : STD_LOGIC_VECTOR (15 downto 0);
        signal mux_selector : STD_LOGIC;
        
        component dsp_multiply_and_accumulate is
            Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
                   b : in STD_LOGIC_VECTOR (15 downto 0);
                   clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   M2_select : in STD_LOGIC;
                   output : out STD_LOGIC_VECTOR (31 downto 0));
        end component;
        
        signal dsp_reset : STD_LOGIC;
    begin
        mux_selector <= NOT Reset AND ND;
    
        --Only M1 is implemented here; M2 is done in the DSP
        M1 <= B when mux_selector = '1' else 
              (others => '0');
    
        Bout <= Buf1;
        process (Clk) begin
            if rising_edge(Clk) then
                Buf1 <= M1;
            end if;
        end process;
        
        dsp_reset <= Reset OR EODDelay;
        multiplier : dsp_multiply_and_accumulate
        port map (
            a => M1,
            b => A,
            clk => Clk,
            reset => dsp_reset,
            M2_select => mux_selector,
            output => multiplier_out
        );
    end block mult_mux_selects;

    inputs : process (Clk) begin
        if rising_edge(Clk) then
            A <= Ain;
            B <= Bin;
            ND <= NDin;
            EOD <= EODin;
            
            EODDelay <= EOD;
        end if;
    end process inputs;
    
    ready_reg : process (Clk) begin
        if rising_edge(Clk) then
            L1 <= ND;
            BRdy <= L1;
        end if;
    end process ready_reg;
    
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

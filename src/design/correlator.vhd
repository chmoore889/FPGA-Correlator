library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity correlator is
    Generic (
        numDelays : integer := 8;
        additionalLatency : integer := 0
    );
    Port ( Clk : in STD_LOGIC;
           Ain : in STD_LOGIC_VECTOR (15 downto 0);
           Bin : in STD_LOGIC_VECTOR (15 downto 0);
           NDin : in STD_LOGIC;
           EODin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (46 downto 0);
           Nin : in STD_LOGIC_VECTOR (15 downto 0);
           DinRdy : in STD_LOGIC;
           Aout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           Bout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           BRdy : out STD_LOGIC := '0';
           EODout : out STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (46 downto 0) := (others => '0');
           Nout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           DoutRdy : out STD_LOGIC := '0');
end correlator;

architecture Behavioral of correlator is
    component multiplication_accumulator is
        Port ( Clk : in STD_LOGIC;
           Ain : in STD_LOGIC_VECTOR (15 downto 0);
           Bin : in STD_LOGIC_VECTOR (15 downto 0);
           NDin : in STD_LOGIC;
           EODin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (46 downto 0);
           Nin : in STD_LOGIC_VECTOR (15 downto 0);
           DinRdy : in STD_LOGIC;
           Aout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           Bout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           BRdy : out STD_LOGIC := '0';
           EODout : out STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (46 downto 0) := (others => '0');
           Nout : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           DoutRdy : out STD_LOGIC := '0');
    end component;
    
    signal EODinDelayed : STD_LOGIC;
    
    type DArr is ARRAY (integer range <>) of STD_LOGIC_VECTOR (Dout'RANGE);
    type Arr16 is ARRAY (integer range <>) of STD_LOGIC_VECTOR (15 downto 0);
    
    --Connections between each multiplication accumulator.
    --(I) refers to connections to the next module.
    --(I-1) is the previous.
    signal A_cascade, B_cascade, N_cascade : Arr16 (numDelays-1 downto 0) := (others => (others => '0'));
    signal D_cascade : DArr (numDelays-1 downto 0) := (others => (others => '0'));
    signal DRdy_cascade, BRdy_cascade, EOD_cascade : STD_LOGIC_VECTOR (numDelays-1 downto 0) := (others => '0');
begin
    --Cascade connections of last module to the outside of this entity
    Aout <= A_cascade(A_cascade'HIGH);
    Bout <= B_cascade(B_cascade'HIGH);
    BRdy <= BRdy_cascade(BRdy_cascade'HIGH);
    EODout <= EODin;
    D_cascade(D_cascade'HIGH) <= Din;
    DRdy_cascade(DRdy_cascade'HIGH) <= DinRdy;
    N_cascade(N_cascade'HIGH) <= Nin;
    
    eod_delay : block
        signal EODinPipe : STD_LOGIC_VECTOR(additionalLatency downto 0) := (others => '0');
    begin
        EODinDelayed <= EODinPipe(additionalLatency);
        EODinPipe(0) <= EODin;
        
        delay : if additionalLatency > 0 generate
            process(clk) begin
                if rising_edge(clk) then
                    if Reset = '1' then
                        EODinPipe(EODinPipe'HIGH downto 1) <= (others => '0');
                    else
                        EODinPipe(EODinPipe'HIGH downto 1) <= EODinPipe(EODinPipe'HIGH - 1 downto 0);
                    end if;
                end if;
            end process;
        end generate delay;
    end block eod_delay;

    mult_accums : for I in 0 to numDelays-1 generate
        first : if I = 0 generate
            mult_first : multiplication_accumulator
            port map (
                Clk => clk,
                Reset => Reset,
                Ain => Ain,
                Bin => Bin,
                NDin => NDin,
                EODin => EODinDelayed,
                Din => D_cascade(I),
                DinRdy => DRdy_cascade(I),
                Nin => N_cascade(I),
                Aout => A_cascade(I),
                Bout => B_cascade(I),
                BRdy => BRdy_cascade(I),
                EODout => EOD_cascade(I),
                Dout => Dout,
                DoutRdy => DoutRdy,
                Nout => Nout
            );
        end generate first;

        other : if I > 0 generate 
            mult_other : multiplication_accumulator
            port map (
                Clk => clk,
                Reset => Reset,
                Ain => A_cascade(I - 1),
                Bin => B_cascade(I - 1),
                NDin => BRdy_cascade(I - 1),
                EODin => EOD_cascade(I - 1),
                Din => D_cascade(I),
                DinRdy => DRdy_cascade(I),
                Nin => N_cascade(I),
                Aout => A_cascade(I),
                Bout => B_cascade(I),
                BRdy => BRdy_cascade(I),
                EODout => EOD_cascade(I),
                Dout => D_cascade(I - 1),
                DoutRdy => DRdy_cascade(I - 1),
                Nout => N_cascade(I - 1)
            );
        end generate other;
    end generate; 
end Behavioral;

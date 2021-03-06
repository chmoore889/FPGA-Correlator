library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use work.time_multiplex.ALL;

entity multi_tau_correlator is
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
end multi_tau_correlator;

architecture Behavioral of multi_tau_correlator is
    component correlator is
        Generic (
            numDelays : integer := 8;
            additionalLatency : integer := 0;
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
    end component;
    
    component combiner is
        Generic (
            numChannels : integer
        );
        Port ( clk : in STD_LOGIC;
               ChaInSel : in STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
               Din : in STD_LOGIC_VECTOR (15 downto 0);
               EODin : in STD_LOGIC;
               NDin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               ChaOutSel : out STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
               Dout : out STD_LOGIC_VECTOR (15 downto 0);
               DRdy : out STD_LOGIC;
               EODout : out STD_LOGIC);
    end component;
    
    COMPONENT int32_to_single
        PORT (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT single_divider
        PORT (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_b_tvalid : IN STD_LOGIC;
            s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    component scaler is
        Generic (
            numChannels : integer
        );
        Port ( Clk : in STD_LOGIC;
               Din : in STD_LOGIC_VECTOR (31 downto 0);
               DinRdy : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
               DoutRdy : out STD_LOGIC := '0');
    end component;
    
    constant num_combiners : integer := 8;
    
    type CHA_SEL_ARRAY is array (natural range <>) of std_logic_vector(ChaInSel'RANGE);
    
    --Connections between each block.
    --(I) refers to connections to the next module.
    --(I-1) is the previous.
    signal A_cascade, B_cascade : STD_LOGIC_DinARRAY (num_combiners downto 0) := (others => (others => '0'));
    signal N_cascade : STD_LOGIC_NARRAY (num_combiners downto 0) := (others => (others => '0'));
    signal D_cascade : STD_LOGIC_DARRAY (num_combiners downto 0) := (others => (others => '0'));
    signal DRdy_cascade, BRdy_cascade, EOD_cascade : STD_LOGIC_VECTOR (num_combiners downto 0) := (others => '0');
    signal ChaSel_cascade : CHA_SEL_ARRAY (num_combiners downto 0) := (others => (others => '0'));
    
    signal Dout_Int : STD_LOGIC_VECTOR (31 downto 0);
    signal Nout_Int : STD_LOGIC_VECTOR (15 downto 0);
    signal Dout_Int_Rdy : STD_LOGIC;
begin
    normalize : block
        signal Dout_Single, Nout_Single : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        signal Dout_Single_Rdy, Nout_Single_Rdy : STD_LOGIC := '0';
        
        signal Dout_unscaled : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        signal Dout_unscaled_Rdy : STD_LOGIC := '0';
        
        signal Reset_invert : STD_LOGIC;
    begin
        Reset_invert <= NOT Reset;
    
        D : int32_to_single
        port map (
            aclk => Clk,
            aresetn => Reset_invert,
            s_axis_a_tvalid => Dout_Int_Rdy,
            s_axis_a_tdata => Dout_Int,
            m_axis_result_tvalid => Dout_Single_Rdy,
            m_axis_result_tdata => Dout_Single
        );
        
        N : int32_to_single
        port map (
            aclk => Clk,
            aresetn => Reset_invert,
            s_axis_a_tvalid => Dout_Int_Rdy,
            s_axis_a_tdata(31 downto 16) => (others => '0'),
            s_axis_a_tdata(Nout_Int'RANGE) => Nout_Int,
            m_axis_result_tvalid => Nout_Single_Rdy,
            m_axis_result_tdata => Nout_Single
        );
        
        divider : single_divider
        port map (
            aclk => Clk,
            aresetn => Reset_invert,
            s_axis_a_tvalid => Dout_Single_Rdy,
            s_axis_a_tdata => Dout_Single,
            s_axis_b_tvalid => Nout_Single_Rdy,
            s_axis_b_tdata => Nout_Single,
            m_axis_result_tvalid => Dout_unscaled_Rdy,
            m_axis_result_tdata => Dout_unscaled
        );
        
        scale : scaler
        generic map (
            numChannels => numChannels
        )
        port map (
            Clk => Clk,
            Din => Dout_unscaled,
            DinRdy => Dout_unscaled_Rdy,
            Reset => Reset,
            Dout => Dout,
            DoutRdy => DoutRdy
        );
    end block normalize;

    first_sdc : correlator
    generic map (
        numDelays => 16,
        additionalLatency => num_combiners,
        numChannels => numChannels
    )
    port map (
        Clk => Clk,
        ChaInSel => ChaInSel,
        Ain => Ain,
        Bin => Bin,
        NDin => NDin,
        EODin => EODin,
        Reset => Reset,
        Din => D_cascade(0),
        Nin => N_cascade(0),
        DinRdy => DRdy_cascade(0),
        ChaOutSel => ChaSel_cascade(0),
        Aout => A_cascade(0),
        Bout => B_cascade(0),
        BRdy => BRdy_cascade(0),
        EODout => EOD_cascade(0),
        Dout => Dout_Int,
        Nout => Nout_Int,
        DoutRdy => Dout_Int_Rdy
    );
    
    other : for I in 1 to num_combiners generate
        combiners_and_correlator : block
            signal A_combiner_Dout, B_combiner_Dout : STD_LOGIC_VECTOR (15 downto 0);
            signal A_DRdy, B_DRdy, A_EODout, B_EODout : STD_LOGIC;
            signal ChaSel : STD_LOGIC_VECTOR (ChaInSel'RANGE);
            
            signal correlator_NDin, correlator_EODin : STD_LOGIC;
        begin
            combine_A : combiner
            generic map (
                numChannels => numChannels
            )
            port map (
                clk => Clk,
                ChaInSel => ChaSel_cascade(I - 1),
                Din => A_cascade(I - 1),
                EODin => EOD_cascade(I - 1),
                NDin => BRdy_cascade(I - 1),
                Reset => Reset,
                ChaOutSel => ChaSel,
                Dout => A_combiner_Dout,
                DRdy => A_DRdy,
                EODout => A_EODout
            );
            
            combine_B : combiner
            generic map (
                numChannels => numChannels
            )
            port map (
                clk => Clk,
                ChaInSel => ChaSel_cascade(I - 1),
                Din => B_cascade(I - 1),
                EODin => EOD_cascade(I - 1),
                NDin => BRdy_cascade(I - 1),
                Reset => Reset,
                --ChaOutSel => ,
                Dout => B_combiner_Dout,
                DRdy => B_DRdy,
                EODout => B_EODout
            );
            
            correlator_NDin <= A_DRdy AND B_DRdy;
            correlator_EODin <= A_EODout AND B_EODout;
            sdc : correlator
            generic map (
                numDelays => 8,
                additionalLatency => num_combiners - I,
                numChannels => numChannels
            )
            port map (
                Clk => Clk,
                ChaInSel => ChaSel,
                Ain => A_combiner_Dout,
                Bin => B_combiner_Dout,
                NDin => correlator_NDin,
                EODin => correlator_EODin,
                Reset => Reset,
                Din => D_cascade(I),
                Nin => N_cascade(I),
                DinRdy => DRdy_cascade(I),
                ChaOutSel => ChaSel_cascade(I),
                Aout => A_cascade(I),
                Bout => B_cascade(I),
                BRdy => BRdy_cascade(I),
                EODout => EOD_cascade(I),
                Dout => D_cascade(I - 1),
                Nout => N_cascade(I - 1),
                DoutRdy => DRdy_cascade(I - 1)
            );
        end block;
    end generate other;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.time_multiplex.ALL;

entity top is
    Port ( Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           UART_tx : out STD_LOGIC;
           UART_rx : in STD_LOGIC);
end top;

architecture Behavioral of top is
    component UART
        Generic (
            CLK_FREQ      : integer := 50e6;   -- system clock frequency in Hz
            BAUD_RATE     : integer := 115200; -- baud rate value
            PARITY_BIT    : string  := "none"; -- type of parity: "none", "even", "odd", "mark", "space"
            USE_DEBOUNCER : boolean := True    -- enable/disable debouncer
        );
        Port (
            -- CLOCK AND RESET
            CLK          : in  std_logic; -- system clock
            RST          : in  std_logic; -- high active synchronous reset
            -- UART INTERFACE
            UART_TXD     : out std_logic; -- serial transmit data
            UART_RXD     : in  std_logic; -- serial receive data
            -- USER DATA INPUT INTERFACE
            DIN          : in  std_logic_vector(7 downto 0); -- input data to be transmitted over UART
            DIN_VLD      : in  std_logic; -- when DIN_VLD = 1, input data (DIN) are valid
            DIN_RDY      : out std_logic; -- when DIN_RDY = 1, transmitter is ready and valid input data will be accepted for transmiting
            -- USER DATA OUTPUT INTERFACE
            DOUT         : out std_logic_vector(7 downto 0); -- output data received via UART
            DOUT_VLD     : out std_logic; -- when DOUT_VLD = 1, output data (DOUT) are valid (is assert only for one clock cycle)
            FRAME_ERROR  : out std_logic; -- when FRAME_ERROR = 1, stop bit was invalid (is assert only for one clock cycle)
            PARITY_ERROR : out std_logic  -- when PARITY_ERROR = 1, parity bit was invalid (is assert only for one clock cycle)
        );
    end component UART;
    
    component UART_interface
        Generic (
            numChannels : integer
        );
        Port ( Clk : in STD_LOGIC;
               Rst : in STD_LOGIC;
               UARTDin : in STD_LOGIC_VECTOR (7 downto 0);
               UARTDinRdy : in STD_LOGIC;
               CorrData : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
               CorrDataRdy : out STD_LOGIC := '0';
               CorrEOD : out STD_LOGIC := '0';
               ChaInSel : out STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0));
    end component UART_interface;
    
    COMPONENT corr_out_fifo
        PORT (
            clk : IN STD_LOGIC;
            srst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            valid : OUT STD_LOGIC
        );
    END COMPONENT;
    
    component multi_tau_correlator is
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
    
    component linear_correlator is
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
    
    constant numChannels : integer := 1;
    constant isMultiTau : boolean := false;
    
    signal DinCorr : STD_LOGIC_VECTOR (15 downto 0);
    signal ChaInSel : STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0);
    signal NDinCorr, EODinCorr : STD_LOGIC;
    
    signal DoutCorr : STD_LOGIC_VECTOR (31 downto 0);
    signal DoutFIFO : STD_LOGIC_VECTOR (7 downto 0);
    signal DoutRdyCorr, DoutRdyFIFO, UARTDinRdy : STD_LOGIC;
    
    signal UARTDout : STD_LOGIC_VECTOR (7 downto 0);
    signal UARTDoutRdy : STD_LOGIC;
    
    signal invert_rst : STD_LOGIC;
begin
    invert_rst <= NOT Rst;

    UART_COM : UART
    GENERIC MAP (
        CLK_FREQ => 100e6,
        BAUD_RATE => 3_125_000,
        PARITY_BIT => "none",
        USE_DEBOUNCER => FALSE
    )
    PORT MAP (
        CLK => Clk,
        RST => invert_rst,
        UART_TXD => UART_tx,
        UART_RXD => UART_rx,
        DIN => DoutFIFO,
        DIN_VLD => DoutRdyFIFO,
        DIN_RDY => UARTDinRdy,
        DOUT => UARTDout,
        DOUT_VLD => UARTDoutRdy
--        FRAME_ERROR => ,
--        PARITY_ERROR => 
    );
    
    interface : UART_interface
    generic map (
        numChannels => numChannels
    )
    port map (
        Clk => Clk,
        Rst => invert_rst,
        UARTDin => UARTDout,
        UARTDinRdy => UARTDoutRdy,
        CorrData => DinCorr,
        CorrDataRdy => NDinCorr,
        CorrEOD => EODinCorr,
        ChaInSel => ChaInSel
    );
    
    corr_out : corr_out_fifo
    PORT MAP (
        clk => Clk,
        srst => invert_rst,
        din => DoutCorr,
        wr_en => DoutRdyCorr,
        rd_en => UARTDinRdy,
        dout => DoutFIFO,
--        full => full,
--        empty => empty,
        valid => DoutRdyFIFO
    );
    
    gen_mt_correlator : if isMultiTau generate 
        multi_tau : multi_tau_correlator
        generic map (
            numChannels => numChannels
        )
        port map (
            Clk => Clk,
            Reset => invert_rst,
            ChaInSel => ChaInSel,
            Ain => DinCorr,
            Bin => DinCorr,
            NDin => NDinCorr,
            EODin => EODinCorr,
            Dout => DoutCorr,
            DoutRdy => DoutRdyCorr
        );
    end generate;
    
    gen_linear_correlator : if NOT isMultiTau generate 
        linear : linear_correlator
        generic map (
            numChannels => numChannels
        )
        port map (
            Clk => Clk,
            Reset => invert_rst,
            ChaInSel => ChaInSel,
            Ain => DinCorr,
            Bin => DinCorr,
            NDin => NDinCorr,
            EODin => EODinCorr,
            Dout => DoutCorr,
            DoutRdy => DoutRdyCorr
        );
    end generate;
end Behavioral;

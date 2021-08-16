library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           UART_tx : out STD_LOGIC;
           UART_rx : in STD_LOGIC);
end top;

architecture Behavioral of top is
    COMPONENT microblaze_controller
      PORT (
        Clk : IN STD_LOGIC;
        Reset : IN STD_LOGIC;
        UART_Interrupt : OUT STD_LOGIC;
        GPI2_Interrupt : OUT STD_LOGIC;
        INTC_IRQ : OUT STD_LOGIC;
        UART_rxd : IN STD_LOGIC;
        UART_txd : OUT STD_LOGIC;
        GPIO1_tri_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO1_tri_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        GPIO2_tri_i : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        GPIO2_tri_o : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        GPIO3_tri_o : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
    END COMPONENT;
    
    component multi_tau_correlator is
        Port ( Clk : in STD_LOGIC;
               Din : in STD_LOGIC_VECTOR (15 downto 0);
               NDin : in STD_LOGIC;
               EODin : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Dout : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
               DoutRdy : out STD_LOGIC := '0');
    end component;
    
    signal Din : STD_LOGIC_VECTOR (15 downto 0);
    signal NDin : STD_LOGIC;
    signal EODin : STD_LOGIC;
    
    signal Dout : STD_LOGIC_VECTOR (31 downto 0);
    signal DoutRdy : STD_LOGIC;
begin
    microblaze : microblaze_controller
    PORT MAP (
        Clk => Clk,
        Reset => Rst,
        --UART_Interrupt => UART_Interrupt,
        --GPI2_Interrupt => ,
        --INTC_IRQ => INTC_IRQ,
        UART_rxd => UART_rx,
        UART_txd => UART_tx,
        GPIO1_tri_i => Dout,
        GPIO1_tri_o => Din,
        GPIO2_tri_i(0) => DoutRdy,
        GPIO2_tri_o(0) => NDin,
        GPIO3_tri_o(0) => EODin
    );
    
    correlator : multi_tau_correlator
    port map (
        Clk => Clk,
        Reset => Rst,
        Din => Din,
        NDin => NDin,
        EODin => EODin,
        Dout => Dout,
        DoutRdy => DoutRdy
    );
end Behavioral;

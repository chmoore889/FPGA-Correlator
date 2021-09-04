library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity uart_interface_testbench is
end uart_interface_testbench;

architecture Behavioral of uart_interface_testbench is
    constant CLOCK_PERIOD : time := 10ns;
    signal clock : std_logic := '0';

    component UART_interface
        Port ( Clk : in STD_LOGIC;
               Rst : in STD_LOGIC;
               UARTDin : in STD_LOGIC_VECTOR (7 downto 0);
               UARTDinRdy : in STD_LOGIC;
               CorrData : out STD_LOGIC_VECTOR (15 downto 0);
               CorrDataRdy : out STD_LOGIC;
               CorrEOD : out STD_LOGIC);
    end component UART_interface;
    
    signal UARTData : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal UARTDataRdy : STD_LOGIC := '0';
    
    signal DinCorr : STD_LOGIC_VECTOR (15 downto 0);
    signal NDinCorr, EODinCorr, Rst : STD_LOGIC := '0';
begin
    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;

    interface : UART_interface
    port map (
        Clk => clock,
        Rst => Rst,
        UARTDin => UARTData,
        UARTDinRdy => UARTDataRdy,
        CorrData => DinCorr,
        CorrDataRdy => NDinCorr,
        CorrEOD => EODinCorr
    );
    
    process begin
        UARTDataRdy <= '1';
    
        for I in 1 to 10 loop
            UARTData <= X"FF"; 
            wait for CLOCK_PERIOD;
            
            UARTData <= std_logic_vector(to_unsigned(I, UARTData'LENGTH)); 
            wait for CLOCK_PERIOD;

            UARTData <= std_logic_vector(to_unsigned(I, UARTData'LENGTH));
            wait for CLOCK_PERIOD;
        end loop;
        
        UARTData <= X"55"; 
        wait for CLOCK_PERIOD;
        
        UARTDataRdy <= '0';
        wait until falling_edge(NDinCorr);
        
        finish;
    end process;
end Behavioral;

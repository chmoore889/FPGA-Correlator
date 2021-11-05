library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;

entity top_test is
end top_test;

architecture Behavioral of top_test is
    constant CLOCK_PERIOD : time := 10ns;
    signal clock : std_logic := '0';
    
    constant BAUD_RATE : integer := 3_125_000;
    constant BAUD_PERIOD : time := 1sec / BAUD_RATE;
    
    component top is
        Port ( Clk : in STD_LOGIC;
               Rst : in STD_LOGIC;
               UART_tx : out STD_LOGIC;
               UART_rx : in STD_LOGIC);
    end component top;
    
    signal Rst : std_logic := '1';
    signal Tx, Rx : std_logic := '1';
    
    
    procedure write_Tx (
        to_write : in STD_LOGIC_VECTOR(7 downto 0);
        signal tx : out STD_LOGIC
    ) is
    begin
        --Start bit
        tx <= '0';
        wait for BAUD_PERIOD;
    
        for I in 0 to 7 loop
            tx <= to_write(I);
            wait for BAUD_PERIOD;
        end loop;
        
        --Stop bit
        tx <= '1';
        wait for BAUD_PERIOD;
    end write_Tx;
begin
    under_test : top
    port map(
        Clk => clock,
        Rst => Rst,
        UART_tx => Rx,
        UART_rx => Tx
    );

    clock_driver : process
    begin
        wait for CLOCK_PERIOD/2;
        clock <= NOT clock;
    end process clock_driver;

    test_in : process begin
        wait for 200 ns;
        
        Rst <= '0';
        wait for CLOCK_PERIOD * 2;
        Rst <= '1';
        wait for CLOCK_PERIOD;
        
        for X in 1 to 1 loop
            for I in 1 to 5 * 2 loop
                write_Tx(X"FF", Tx);
                
                if I mod 2 = 1 then
                    write_Tx(X"01", Tx);
                else
                    write_Tx(X"02", Tx);
                end if;
                
                write_Tx(X"00", Tx);
            end loop;
            
            write_Tx(X"55", Tx);
            
            wait for 55 * CLOCK_PERIOD;
        end loop;
    
        finish;
    end process;
end Behavioral;

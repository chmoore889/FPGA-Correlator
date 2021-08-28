library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_interface is
    Port ( Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           UARTDin : in STD_LOGIC_VECTOR (7 downto 0);
           UARTDinRdy : in STD_LOGIC;
           CorrData : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           CorrDataRdy : out STD_LOGIC := '0';
           CorrEOD : out STD_LOGIC := '0');
end UART_interface;

architecture Behavioral of UART_interface is
    constant startCode : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant EODCode : STD_LOGIC_VECTOR(7 downto 0) := X"55";

    type STATE is (idle, eod, data_start, data_1, data_2);
    signal curr_state : STATE := idle; 
begin
    process(Clk) begin
        if rising_edge(Clk) then
            if Rst = '1' then
                curr_state <= idle;
            else
                case curr_state is
                    when idle =>
                        if UARTDinRdy = '1' then
                            if UARTDin = startCode then
                                curr_state <= data_start;
                                CorrEOD <= '0';
                            elsif UARTDin = EODCode then
                                curr_state <= eod;
                                CorrDataRdy <= '0';
                                CorrEOD <= '1';
                            end if;
                        end if;
                    when eod =>
                        if UARTDin = startCode then
                            curr_state <= data_start;
                            CorrEOD <= '0';
                        else
                            curr_state <= idle;
                            CorrDataRdy <= '0';
                            CorrEOD <= '0';
                        end if;
                    when data_start =>
                        if UARTDinRdy = '1' then
                            curr_state <= data_1;
                            CorrData(7 downto 0) <= UARTDin;
                        end if;
                    when data_1 =>
                        if UARTDinRdy = '1' then
                            curr_state <= data_2;
                            CorrData(15 downto 8) <= UARTDin;
                            CorrDataRdy <= '1';
                        end if;
                    when data_2 =>
                        if UARTDin = EODCode then
                            curr_state <= eod;
                            CorrDataRdy <= '0';
                            CorrEOD <= '1';
                        else
                            curr_state <= idle;
                            CorrDataRdy <= '0';
                            CorrEOD <= '0';
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity UART_interface is
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
           ChaInSel : out STD_LOGIC_VECTOR (channels_to_bits(numChannels) - 1 downto 0) := (others => '0'));
end UART_interface;

architecture Behavioral of UART_interface is
    COMPONENT data_storage_fifo
        PORT (
            clk : IN STD_LOGIC;
            srst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            valid : OUT STD_LOGIC;
            underflow : OUT STD_LOGIC
        );
    END COMPONENT;

    constant startCode : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant EODCode : STD_LOGIC_VECTOR(7 downto 0) := X"55";

    type STATE is (idle, eod, data_1, data_2);
    signal curr_state : STATE := idle; 
    
    signal Data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal DataRdy, EODsig : STD_LOGIC := '0';
    
    signal fifo_Data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal rd_en, fifo_underflow, fifo_valid : STD_LOGIC := '0';
begin
    output_regs : block
        signal EOD_pulsed, CorrDataRdyReg : STD_LOGIC := '0';
        
        constant data_count_max : integer := numChannels - 1;
        signal data_count : UNSIGNED (ChaInSel'RANGE) := (others => '0');
    begin
        ChaInSel <= std_logic_vector(data_count);
        CorrDataRdy <= CorrDataRdyReg;
    
        process(Clk) begin
            if rising_edge(Clk) then
                if Rst = '1' then
                    CorrData <= (others => '0');
                    CorrDataRdyReg <= '0';
                    CorrEOD <= '0';
                    EOD_pulsed <= '0';
                    data_count <= (others => '0');
                else
                    CorrData <= fifo_Data;
                    CorrDataRdyReg <= fifo_valid;
                    
                    if CorrDataRdyReg = '1' then
                        --Handle counter overflow
                        if data_count = data_count_max then
                            data_count <= (others => '0');
                        else
                            data_count <= data_count + 1;
                        end if;
                    end if;
                    
                    if fifo_underflow = '1' then
                        if EOD_pulsed = '0' then
                            CorrEOD <= '1';
                            EOD_pulsed <= '1';
                            
                            data_count <= (others => '0');
                        else
                            CorrEOD <= '0';
                        end if;
                    else
                        CorrEOD <= '0';
                        EOD_pulsed <= '0';
                    end if;
                end if;
            end if;
        end process;
    end block output_regs;

    data_store : data_storage_fifo
    PORT MAP (
        clk => Clk,
        srst => Rst,
        din => Data,
        wr_en => DataRdy,
        rd_en => rd_en,
        dout => fifo_Data,
--        full => full,
--        empty => fifo_empty,
        valid => fifo_valid,
        underflow => fifo_underflow
    );
    
    dump_data : process(Clk) begin
        if rising_edge(Clk) then
            if Rst = '1' OR fifo_underflow = '1' then
                rd_en <= '0';
            elsif EODsig = '1' then
                rd_en <= '1';
            end if;
        end if;
    end process dump_data;

    process(Clk) begin
        if rising_edge(Clk) then
            if Rst = '1' then
                curr_state <= idle;
            else
                case curr_state is
                    when idle =>
                        DataRdy <= '0';
                        EODsig <= '0';

                        if UARTDinRdy = '1' then
                            if UARTDin = startCode then
                                curr_state <= data_1;
                            elsif UARTDin = EODCode then
                                curr_state <= eod;
                                EODsig <= '1';
                            end if;
                        end if;
                    when eod =>
                        EODsig <= '0';
                    
                        if UARTDinRdy = '1' AND UARTDin = startCode then
                            curr_state <= data_1;
                        else
                            curr_state <= idle;
                        end if;
                    when data_1 =>
                        if UARTDinRdy = '1' then
                            curr_state <= data_2;
                            
                            Data(7 downto 0) <= UARTDin;
                        end if;
                    when data_2 =>
                        if UARTDinRdy = '1' then
                            curr_state <= idle;
                            
                            Data(15 downto 8) <= UARTDin;
                            DataRdy <= '1';
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
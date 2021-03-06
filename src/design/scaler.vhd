library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.time_multiplex.ALL;

entity scaler is
    Generic (
        numChannels : integer
    );
    Port ( Clk : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (31 downto 0);
           DinRdy : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           DoutRdy : out STD_LOGIC := '0');
end scaler;

architecture Behavioral of scaler is
    component counter is
        Generic (
            maxVal : integer
        );
        Port ( enable : in STD_LOGIC;
               clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               count : out STD_LOGIC_VECTOR (channels_to_bits(maxVal) - 1 downto 0));
    end component;
    
    constant count_max : integer := numChannels * 8 - 1;

    signal orig_exponent, new_exponent : STD_LOGIC_VECTOR (7 downto 0);
    signal num_to_divide : UNSIGNED (3 downto 0) := (others => '0');
    signal first_8_done : STD_LOGIC := '0';
    
    signal count : STD_LOGIC_VECTOR (channels_to_bits(count_max) - 1 downto 0);
    signal counter_reset : STD_LOGIC;
    
    signal DoutReg : STD_LOGIC_VECTOR (31 downto 0);
    signal DoutRdyReg : STD_LOGIC;
begin
    DoutReg <= Din(31) & new_exponent & Din(22 downto 0);
    DoutRdyReg <= DinRdy;

    orig_exponent <= Din(30 downto 23);
    --When Din is 0, don't do scaling
    new_exponent <= orig_exponent when Din(30 downto 0) = (30 downto 0 => '0') OR Din(30 downto 23) = (30 downto 23 => '1') else
                    std_logic_vector(unsigned(orig_exponent) - (2 * num_to_divide));
    
    process (clk) begin
        if rising_edge(clk) then
            if counter_reset = '1' then
                first_8_done <= '0';
                num_to_divide <= (others => '0');
            elsif count = std_logic_vector(to_unsigned(count_max, count'HIGH + 1)) then
                if first_8_done = '1' then
                    num_to_divide <= num_to_divide + 1;
                else
                    first_8_done <= '1';
                end if;
            end if;
        end if;
    end process;
    
    counter_reset <= (NOT DinRdy) OR Reset;
    counter_inst : counter
    generic map(
        maxVal => count_max
    )
    port map(
        clk => Clk,
        enable => DinRdy,
        reset => counter_reset,
        count => count
    );
    
    output_regs : process (clk) begin
        if rising_edge(clk) then
            if counter_reset = '1' then
                Dout <= (others => '0');
                DoutRdy <= '0';
            else
                Dout <= DoutReg;
                DoutRdy <= DoutRdyReg;
            end if;
        end if;
    end process output_regs;
end Behavioral;

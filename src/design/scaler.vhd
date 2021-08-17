library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scaler is
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
            countBitSize : integer
        );
        Port ( enable : in STD_LOGIC;
               clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               count : out STD_LOGIC_VECTOR (countBitSize - 1 downto 0));
    end component;

    signal orig_exponent, new_exponent : STD_LOGIC_VECTOR (7 downto 0);
    signal num_to_divide : UNSIGNED (3 downto 0) := (others => '0');
    signal first_8_done : STD_LOGIC := '0';
    
    signal count : STD_LOGIC_VECTOR (2 downto 0);
    signal counter_reset : STD_LOGIC;
    
    signal DoutReg : STD_LOGIC_VECTOR (31 downto 0);
    signal DoutRdyReg : STD_LOGIC;
begin
    DoutReg <= Din(31) & new_exponent & Din(22 downto 0);
    DoutRdyReg <= DinRdy;

    orig_exponent <= Din(30 downto 23);    
    new_exponent <= std_logic_vector(unsigned(orig_exponent) - (2 * num_to_divide));
    
    process (clk) begin
        if rising_edge(clk) then
            if counter_reset = '1' then
                first_8_done <= '0';
                num_to_divide <= (others => '0');
            elsif count = "111" then
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
        countBitSize => 3
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

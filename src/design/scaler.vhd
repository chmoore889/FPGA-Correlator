library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scaler is
    Port ( Clk : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (31 downto 0);
           DinRdy : in STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (31 downto 0);
           DoutRdy : out STD_LOGIC);
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
begin
    Dout <= Din(31) & new_exponent & Din(22 downto 0);
    DoutRdy <= DinRdy;

    orig_exponent <= Din(30 downto 23);    
    new_exponent <= std_logic_vector(unsigned(orig_exponent) - (2 * num_to_divide));
    
    process (clk, counter_reset) begin
        if counter_reset = '1' then
            first_8_done <= '0';
            num_to_divide <= (others => '0');
        elsif rising_edge(clk) then
            if count = "111" then
                if first_8_done = '1' then
                    num_to_divide <= num_to_divide + 1;
                else
                    first_8_done <= '1';
                end if;
            end if;
        end if;
    end process;
    
    counter_reset <= NOT DinRdy;
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
end Behavioral;

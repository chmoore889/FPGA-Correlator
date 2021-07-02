library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplication_accumulator is
    Port ( Clk : in STD_LOGIC;
           Ain : in STD_LOGIC_VECTOR (15 downto 0);
           Bin : in STD_LOGIC_VECTOR (15 downto 0);
           ND : in STD_LOGIC;
           EODin : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (31 downto 0);
           Nin : in STD_LOGIC_VECTOR (15 downto 0);
           DinRdy : in STD_LOGIC;
           Aout : out STD_LOGIC_VECTOR (15 downto 0);
           Bout : out STD_LOGIC_VECTOR (15 downto 0);
           BRdy : out STD_LOGIC;
           EODout : out STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (31 downto 0);
           Nout : out STD_LOGIC_VECTOR (15 downto 0);
           DoutRdy : out STD_LOGIC);
end multiplication_accumulator;

architecture Behavioral of multiplication_accumulator is

begin


end Behavioral;

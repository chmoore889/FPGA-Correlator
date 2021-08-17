library IEEE;
library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.vcomponents.all;

entity dsp_multiply_and_accumulate is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           M1_select : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (31 downto 0));
end dsp_multiply_and_accumulate;

architecture Behavioral of dsp_multiply_and_accumulate is
    signal accum : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal sum : STD_LOGIC_VECTOR (47 downto 0) := (others => '0');
    signal inmode : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    
    signal widened_a : STD_LOGIC_VECTOR (29 downto 0) := (others => '0');
    signal widened_b : STD_LOGIC_VECTOR (17 downto 0) := (others => '0');
    signal widened_c : STD_LOGIC_VECTOR (47 downto 0) := (others => '0');
begin
    output <= accum;

    accum_reg : process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                accum <= (others => '0');
            else
                accum <= sum(31 downto 0);
            end if;
        end if;
    end process accum_reg;
    
    -- Using the inmode to implement M1
    inmode <= "000" & (NOT M1_select) & '0';
    
    widened_a <= (widened_a'LEFT downto a'LENGTH => '0') & a;
    widened_b <= (widened_b'LEFT downto b'LENGTH => '0') & b;
    widened_c <= (widened_c'LEFT downto accum'LENGTH => '0') & accum;

    DSP48E1_inst : DSP48E1
    generic map (
       -- Feature Control Attributes: Data Path Selection
       A_INPUT => "DIRECT",               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
       B_INPUT => "DIRECT",               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
       USE_DPORT => FALSE,                -- Select D port usage (TRUE or FALSE)
       USE_MULT => "MULTIPLY",            -- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
       USE_SIMD => "ONE48",               -- SIMD selection ("ONE48", "TWO24", "FOUR12")
       -- Pattern Detector Attributes: Pattern Detection Configuration
       AUTORESET_PATDET => "NO_RESET",    -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
       MASK => X"3fffffffffff",           -- 48-bit mask value for pattern detect (1=ignore)
       PATTERN => X"000000000000",        -- 48-bit pattern match for pattern detect
       SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
       SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
       USE_PATTERN_DETECT => "NO_PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
       -- Register Control Attributes: Pipeline Register Configuration
       ACASCREG => 0,                     -- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
       ADREG => 1,                        -- Number of pipeline stages for pre-adder (0 or 1)
       ALUMODEREG => 0,                   -- Number of pipeline stages for ALUMODE (0 or 1)
       AREG => 0,                         -- Number of pipeline stages for A (0, 1 or 2)
       BCASCREG => 0,                     -- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
       BREG => 0,                         -- Number of pipeline stages for B (0, 1 or 2)
       CARRYINREG => 0,                   -- Number of pipeline stages for CARRYIN (0 or 1)
       CARRYINSELREG => 0,                -- Number of pipeline stages for CARRYINSEL (0 or 1)
       CREG => 0,                         -- Number of pipeline stages for C (0 or 1)
       DREG => 1,                         -- Number of pipeline stages for D (0 or 1)
       INMODEREG => 0,                    -- Number of pipeline stages for INMODE (0 or 1)
       MREG => 0,                         -- Number of multiplier pipeline stages (0 or 1)
       OPMODEREG => 0,                    -- Number of pipeline stages for OPMODE (0 or 1)
       PREG => 0                         -- Number of pipeline stages for P (0 or 1)
    )
    port map (
       -- Cascade: 30-bit (each) output: Cascade Ports
       --ACOUT => ACOUT,                   -- 30-bit output: A port cascade output
       --BCOUT => BCOUT,                   -- 18-bit output: B port cascade output
       --CARRYCASCOUT => CARRYCASCOUT,     -- 1-bit output: Cascade carry output
       --MULTSIGNOUT => MULTSIGNOUT,       -- 1-bit output: Multiplier sign cascade output
       --PCOUT => PCOUT,                   -- 48-bit output: Cascade output
       -- Control: 1-bit (each) output: Control Inputs/Status Bits
       --OVERFLOW => OVERFLOW,             -- 1-bit output: Overflow in add/acc output
       --PATTERNBDETECT => PATTERNBDETECT, -- 1-bit output: Pattern bar detect output
       --PATTERNDETECT => PATTERNDETECT,   -- 1-bit output: Pattern detect output
       --UNDERFLOW => UNDERFLOW,           -- 1-bit output: Underflow in add/acc output
       -- Data: 4-bit (each) output: Data Ports
       --CARRYOUT => CARRYOUT,             -- 4-bit output: Carry output
       P => sum,                           -- 48-bit output: Primary data output
       -- Cascade: 30-bit (each) input: Cascade Ports
       ACIN => (others => '0'),                     -- 30-bit input: A cascade data input
       BCIN => (others => '0'),                     -- 18-bit input: B cascade input
       CARRYCASCIN => '0',       -- 1-bit input: Cascade carry input
       MULTSIGNIN => '0',         -- 1-bit input: Multiplier sign input
       PCIN => (others => '0'),                     -- 48-bit input: P cascade input
       -- Control: 4-bit (each) input: Control Inputs/Status Bits
       ALUMODE => "0000",               -- 4-bit input: ALU control input
       CARRYINSEL => "000",         -- 3-bit input: Carry select input
       CLK => clk,                       -- 1-bit input: Clock input
       INMODE => inmode,                 -- 5-bit input: INMODE control input
       OPMODE => "0110101",                 -- 7-bit input: Operation mode input
       -- Data: 30-bit (each) input: Data Ports
       A => widened_a,                           -- 30-bit input: A data input
       B => widened_b,                           -- 18-bit input: B data input
       C => widened_c,                           -- 48-bit input: C data input
       CARRYIN => '0',               -- 1-bit input: Carry input signal
       D => (others => '0'),                           -- 25-bit input: D data input
       -- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
       CEA1 => '0',                     -- 1-bit input: Clock enable input for 1st stage AREG
       CEA2 => '0',                     -- 1-bit input: Clock enable input for 2nd stage AREG
       CEAD => '0',                     -- 1-bit input: Clock enable input for ADREG
       CEALUMODE => '0',           -- 1-bit input: Clock enable input for ALUMODE
       CEB1 => '0',                     -- 1-bit input: Clock enable input for 1st stage BREG
       CEB2 => '0',                     -- 1-bit input: Clock enable input for 2nd stage BREG
       CEC => '0',                       -- 1-bit input: Clock enable input for CREG
       CECARRYIN => '0',           -- 1-bit input: Clock enable input for CARRYINREG
       CECTRL => '0',                 -- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
       CED => '0',                       -- 1-bit input: Clock enable input for DREG
       CEINMODE => '0',             -- 1-bit input: Clock enable input for INMODEREG
       CEM => '0',                       -- 1-bit input: Clock enable input for MREG
       CEP => '0',                       -- 1-bit input: Clock enable input for PREG
       RSTA => '0',                     -- 1-bit input: Reset input for AREG
       RSTALLCARRYIN => '0',   -- 1-bit input: Reset input for CARRYINREG
       RSTALUMODE => '0',         -- 1-bit input: Reset input for ALUMODEREG
       RSTB => '0',                     -- 1-bit input: Reset input for BREG
       RSTC => '0',                     -- 1-bit input: Reset input for CREG
       RSTCTRL => '0',               -- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
       RSTD => '0',                     -- 1-bit input: Reset input for DREG and ADREG
       RSTINMODE => '0',           -- 1-bit input: Reset input for INMODEREG
       RSTM => '0',                     -- 1-bit input: Reset input for MREG
       RSTP => '0'                      -- 1-bit input: Reset input for PREG
    );
end Behavioral;
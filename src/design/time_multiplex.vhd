library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package time_multiplex is
    type STD_LOGIC_DARRAY is array (natural range <>) of std_logic_vector(31 downto 0);
    type STD_LOGIC_NARRAY is array (natural range <>) of std_logic_vector(15 downto 0);
    type STD_LOGIC_DinARRAY is array (natural range <>) of std_logic_vector(15 downto 0);
    
    --Returns `index`th element of std_logic_aoa
    function arr_select_to_int(
        index : in std_logic_vector)
    return integer;
    
    function channels_to_bits(
        numChannels : in integer)
    return integer;
end package;

package body time_multiplex is
    function arr_select_to_int(
        index : in std_logic_vector)
    return integer is begin
        return to_integer(unsigned(index));
    end;
    
    function channels_to_bits(
        numChannels : in integer)
    return integer is begin
        return integer(ceil(log2(real(numChannels))));
    end;
end package body time_multiplex;
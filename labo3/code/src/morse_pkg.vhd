--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : morse_pkg.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : This package offers some types, constants and methods
--               to manipulate Morse code.
--               Conversion functions from and to ASCII are offered.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 0.1   31.03.2021  YTA        Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package morse_pkg is

    -- Maximum number of symbols in a Morse code (dot + dash)
    constant MORSE_SYMBOL_LENGTH : integer := 5;

    -- Integer to represent the length of a Morse letter
    subtype morse_char_length_t is integer range 0 to MORSE_SYMBOL_LENGTH;

    -- Type to store a Morse code
    -- Represented by its value, where '0's represent a dot and '1's
    -- represent a dash.
    -- size stores the length of the letter code
    type morse_char_t is record
        size  : morse_char_length_t;
        value : std_logic_vector(0 to 4);
    end record;

    -- A simple array of morse_char_t
    type ascii_letter_to_morse_array_t is array (integer range <>) of morse_char_t;

    -- A constant storing the internal Morse representation of the characters
    -- 'A' to 'Z'
    constant letter_conversion_c : ascii_letter_to_morse_array_t(0 to 25) := (
    morse_char_t'(2, "01---"),
    morse_char_t'(4, "1000-"),
    morse_char_t'(4, "1010-"),
    morse_char_t'(3, "100--"),
    morse_char_t'(1, "0----"),
    morse_char_t'(4, "0010-"),
    morse_char_t'(3, "110--"),
    morse_char_t'(4, "0000-"),
    morse_char_t'(2, "00---"),
    morse_char_t'(4, "0111-"),
    morse_char_t'(3, "101--"),
    morse_char_t'(4, "0100-"),
    morse_char_t'(2, "11---"),
    morse_char_t'(2, "10---"),
    morse_char_t'(3, "111--"),
    morse_char_t'(4, "0110-"),
    morse_char_t'(4, "1101-"),
    morse_char_t'(3, "010--"),
    morse_char_t'(3, "000--"),
    morse_char_t'(1, "1----"),
    morse_char_t'(3, "001--"),
    morse_char_t'(4, "0001-"),
    morse_char_t'(3, "011--"),
    morse_char_t'(4, "1001-"),
    morse_char_t'(4, "1011-"),
    morse_char_t'(4, "1100-")
    );

    -- A constant storing the internal Morse representation of the characters
    -- '0' to '9'
    constant number_conversion_c : ascii_letter_to_morse_array_t(0 to 9) := (
    morse_char_t'(5, "01111"),
    morse_char_t'(5, "00111"),
    morse_char_t'(5, "00011"),
    morse_char_t'(5, "00001"),
    morse_char_t'(5, "00000"),
    morse_char_t'(5, "10000"),
    morse_char_t'(5, "11000"),
    morse_char_t'(5, "11100"),
    morse_char_t'(5, "11110"),
    morse_char_t'(5, "11111")
    );

    -- A type embedding a Morse letter and an information about its validity.
    -- If unknown is '1', it means that the character is not valid (not supported)
    type morse_char_or_unknown_t is record
        unknown : std_logic;
        char    : morse_char_t;
    end record;

    -- Converts an ASCII character to a Morse code. The returned value also embeds the information
    -- about the validity of the input ASCII character.
    function ascii_to_morse(ascii : std_logic_vector(7 downto 0)) return morse_char_or_unknown_t;

    -- Converts an internal Morse representation to an ASCII character
    function morse_to_ascii(morse : morse_char_t) return std_logic_vector;

    -- Convecrts an internal Morse representation to an ASCII character.
    -- The 'valid' output is set to '1' if the Morse code is valid, and to '0' else.
    procedure morse_to_ascii_check(morse : morse_char_t; char : out std_logic_vector; valid : out std_logic);

    -- Returns a string representation of a Morse code.
    -- Exemple:      ..--
    function morse_char_to_string(char_in : morse_char_t) return string;

end package;

package body morse_pkg is

    function ascii_to_morse(ascii : std_logic_vector(7 downto 0)) return morse_char_or_unknown_t is
        variable value_v : std_logic_vector(7 downto 0);
    begin
        value_v := to_01(ascii);
        if (unsigned(value_v) = 32) then
            -- This is a space, and will be interpreted as such
            return ('0', (0, "-----"));
        end if;
        if (unsigned(value_v) > 64) and (unsigned(value_v) < 91) then
            return ('0', letter_conversion_c(to_integer(unsigned(ascii)) - 65));
        end if;
        if (unsigned(value_v) > 96) and (unsigned(value_v) < 123) then
            return ('0', letter_conversion_c(to_integer(unsigned(ascii)) - 97));
        end if;
        if (unsigned(value_v) > 47) and (unsigned(value_v) < 58) then
            return ('0', number_conversion_c(to_integer(unsigned(ascii)) - 48));
        end if;
        return ('1', (0, "-----"));
    end;

    function morse_to_ascii(morse : morse_char_t) return std_logic_vector is
        variable result_v : integer;
    begin
        result_v := 0;
        if morse = (0, "-----") then
            result_v := 32;
        else
            for i in number_conversion_c'range loop
                if morse.size = number_conversion_c(i).size and morse.value(0 to number_conversion_c(i).size - 1) = number_conversion_c(i).value(0 to number_conversion_c(i).size - 1) then
                    result_v := 48 + i;
                end if;
            end loop;
            for i in letter_conversion_c'range loop
                if morse.size = letter_conversion_c(i).size and morse.value(0 to letter_conversion_c(i).size - 1) = letter_conversion_c(i).value(0 to letter_conversion_c(i).size - 1) then
                    result_v := 65 + i;
                end if;
            end loop;
        end if;
        return std_logic_vector(to_unsigned(result_v, 8));
    end;


    procedure morse_to_ascii_check(morse : morse_char_t; char : out std_logic_vector; valid : out std_logic) is
        variable result_v : integer;
        variable valid_v : std_logic;
    begin
        result_v := 0;
        valid_v := '0';
        if morse = (0, "-----") then
            result_v := 32;
            valid_v := '1';
        else
            for i in number_conversion_c'range loop
                if morse.size = number_conversion_c(i).size and morse.value(0 to number_conversion_c(i).size - 1) = number_conversion_c(i).value(0 to number_conversion_c(i).size - 1) then
                    result_v := 48 + i;
            valid_v := '1';
                end if;
            end loop;
            for i in letter_conversion_c'range loop
                if morse.size = letter_conversion_c(i).size and morse.value(0 to letter_conversion_c(i).size - 1) = letter_conversion_c(i).value(0 to letter_conversion_c(i).size - 1) then
                    result_v := 65 + i;
            valid_v := '1';
                end if;
            end loop;
        end if;
        char := std_logic_vector(to_unsigned(result_v, 8));
        valid := valid_v;
    end;



    function morse_char_to_string(char_in : morse_char_t) return string is
        variable result_v               : string(1 to char_in.size);
    begin
        for i in 1 to char_in.size loop
            if char_in.value(i - 1) = '0' then
                result_v(i) := '.';
            else
                result_v(i) := '-';
            end if;
        end loop;
        return result_v;
    end morse_char_to_string;


end package body;

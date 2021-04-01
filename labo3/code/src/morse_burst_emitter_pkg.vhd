--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : morse_burst_emitter_pkg.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : This package offers the input/output interface of the
--               Morse burst emitter, thanks to two records.
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

package morse_burst_emitter_pkg is

    -- The input control port of the Morse burst emitter
    type morse_burst_emitter_control_in_t is record
        -- The ASCII character to load
        char      : std_logic_vector(7 downto 0);
        -- '1' -> load char into the component, '0' -> do nothing
        load_char : std_logic;
        -- '1' -> starts a burst transmission, '0' -> do nothing
        send      : std_logic;
        -- When send='1', indicates the number of clock cycles
        -- used as the dot duration.
        -- 28 bits allow for more than half a second at 250 MHz
        dot_period : std_logic_vector(27 downto 0);
    end record;

    -- The output control port of the Morse burst emitter
    type morse_burst_emitter_control_out_t is record
        -- Indicates if the emitter is currently transmitting or not
        busy    : std_logic;
        -- Indicates if the internal FIFO of the emitter is full
        full    : std_logic;
        -- Indicates if the character loaded on the last clock cycle
        -- is not valid (not supported by the system)
        unknown : std_logic;
    end record;

end package;

--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : output_monitor.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : A monitor responsible to observe the Morse signal, and 
--               reconstruct transactions from the observation.
--               It shall also send the transactions, and check everything
--               that happens on the Morse line.
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

library tlmvm;
context tlmvm.tlmvm_context;

library project_lib;
context project_lib.project_ctx;

use work.transactions_pkg.all;

entity output_agent_monitor is
    generic (
        FIFOSIZE                                           : integer := 8;
        procedure blocking_put(variable output_transaction : in output_transaction_t)
    );
    port (
        signal clk         : in std_logic;
        signal rst         : in std_logic;
        signal port_output : in std_logic;
        signal dot_period  : in integer
    );
end output_agent_monitor;

architecture testbench of output_agent_monitor is

begin
    process is

        variable transaction  : output_transaction_t;
        variable counter      : integer;
        variable ok           : boolean;
        variable up_counter   : integer;
        variable down_counter : integer;
        variable char_v       : morse_char_t;
    begin

        -- Waits for the logger initialization
        wait for resolution_limit;

        counter := 0;
        loop
            logger.note("Monitor waiting for transaction number " & integer'image(counter));
            ok := false;

            -- Example here, just detecting dots
            up_counter   := 0;
            down_counter := 0;
            char_v.size  := 0;
            char_v.value := "-----";
            wait until rising_edge(clk);
            while port_output = '0' loop
                wait until rising_edge(clk);
            end loop;

            raise_objection;

            up_counter   := 0;
            down_counter := 0;

            while port_output = '1' loop
                up_counter := up_counter + 1;
                wait until rising_edge(clk);
            end loop;

            if up_counter = dot_period then
                -- Sounds good
                char_v := letter_conversion_c(1); -- Arbitrarily say it's a B
                morse_to_ascii_check(char_v, transaction.char, transaction.valid);
                if transaction.valid = '0' then
                    logger.error("Output Monitor : Error in transaction number " & integer'image(counter) & 
                    ". Output got an invalid series of dots and dashes. Observed: " & morse_char_to_string(char_v));
                end if;
                blocking_put(transaction);
                logger.note("Output Monitor received transaction number " & integer'image(counter) & LF &
                "Value : " & integer'image(to_integer(unsigned(transaction.char))) & LF &
                "Size : " & integer'image(char_v.size));
                counter := counter + 1;
            else
                logger.error("I expected a dot, but that's not what I got");
            end if;

            drop_objection;
        end loop;
        wait;
    end process;

end testbench;
--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : scoreboard.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : A scoreboard to manage the comparison of input and output
--               transactions of the Morse burst emitter
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


entity scoreboard is
    generic (
        FIFOSIZE : integer := 8;
        TESTCASE : integer := 0;
        procedure blocking_get_input(variable input_transaction   : out input_transaction_t);
        procedure blocking_get_output(variable output_transaction : out output_transaction_t)
        );
end scoreboard;


architecture testbench of scoreboard is
begin

    proc_scoreboard : process
        variable trans_input : input_transaction_t;
        variable trans_output : output_transaction_t;
        variable counter      : integer;
        variable expected     : std_logic_vector(FIFOSIZE-1 downto 0);
        variable value : integer;
    begin

        -- Waits just a bit to let the logger initialize correctly
        wait for resolution_limit;

        counter := 0;

        loop
            logger.note("Scoreboard waiting for transaction number " & integer'image(counter));
            blocking_get_input(trans_input);
            if trans_input.command = send then 
                next;
            end if;
            if trans_input.command = nop then 
                next;
            end if;
            
            blocking_get_output(trans_output);
            raise_objection;
            if trans_output.valid = '1' then
                logger.note("Scoreboard received transaction number " & integer'image(counter));
                if(trans_output.char /= trans_input.char) then
                    --logger.note(to_string(trans_output.char) & " " & to_string(trans_input.char));
                    logger.note(integer'image(to_integer(unsigned(trans_output.char))) & " " & integer'image(to_integer(unsigned(trans_input.char))));
                    logger.error("Error ! Results don't match");
                else 
                    logger.note(integer'image(to_integer(unsigned(trans_output.char))) & " " & integer'image(to_integer(unsigned(trans_input.char))));
                    logger.note("Everything's fine !");
                end if;
                -- Check if everything goes well or not
            end if;
            counter := counter + 1;
            drop_objection;
        end loop;


        wait;

    end process;

end testbench;

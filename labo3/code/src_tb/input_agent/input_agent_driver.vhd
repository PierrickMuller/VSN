--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : input_agent_driver.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The driver controlling the Morse burst emitter.
--               It waits for the transactions sent by the sequencer, and plays
--               them by interacting with the DUV.
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

entity input_agent_driver is
    generic (
        FIFOSIZE : integer := 8;
        procedure blocking_get(variable input_transaction : out input_transaction_t)
        );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        port_input  : out morse_burst_emitter_control_in_t;
        port_output : in  morse_burst_emitter_control_out_t
        );
end input_agent_driver;

architecture testbench of input_agent_driver is

begin

    process is
        variable transaction : input_transaction_t;
        variable counter : integer;
    begin

        counter          := 0;
        port_input.char <= (others => '0');
        port_input.load_char <= '0';
        port_input.send <= '0';
        port_input.dot_period <= (others => '0');
        
        -- That's a good idea to wait for the reset to be deactivated
        wait until rst = '0';
        wait until falling_edge(clk);
        wait until falling_edge(clk);

        loop
            logger.note("Driver waiting for transaction number " & integer'image(counter));
            blocking_get(transaction);
            logger.note("Driver received transaction number " & integer'image(counter));
            raise_objection;

            case transaction.command is
                when add_char =>
                    port_input.char <= transaction.char;
                    port_input.dot_period <= transaction.dot_period;
                    port_input.load_char <= '1';
                    while port_output.full = '1' loop
                        wait until falling_edge(clk);
                    end loop;
                when send =>
                    port_input.send <= '1';
                    port_input.dot_period <= transaction.dot_period;
                    while port_output.busy = '1' loop
                        wait until falling_edge(clk);
                    end loop;
                when nop =>
                    null;
            end case;

            wait until falling_edge(clk);
            port_input.send <= '0';
            port_input.load_char <= '0';

            counter          := counter + 1;
            for i in 1 to transaction.waiting_time loop
                wait until falling_edge(clk);
            end loop;
            drop_objection;
        end loop;

        wait;
    end process;

end testbench;

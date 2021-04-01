--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : input_agent_monitor.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The monitor, observing the activity on the control ports of
--               the burst emitter.
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

entity input_agent_monitor is
    generic (
        FIFOSIZE : integer := 8;
        procedure blocking_put(variable input_transaction : input_transaction_t)
        );
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        port_input  : in morse_burst_emitter_control_in_t;
        port_output : in morse_burst_emitter_control_out_t;
        dot_period  : out integer
        );
end input_agent_monitor;

architecture testbench of input_agent_monitor is

begin

    -- This process updates the dot_period signal whenever a new burst starts
    proc_dot_period: process is
    begin
        dot_period <= 0;
        loop
            wait until rising_edge(clk);
            if port_input.send = '1' and port_output.busy = '0' then
                dot_period <= to_integer(unsigned(port_input.dot_period));
            end if;
        end loop;
    end process;

    process is
    begin
        wait for resolution_limit;

        loop
            wait until rising_edge(clk);
            -- Do some checks if required

        end loop;

        wait;
    end process;

end testbench;

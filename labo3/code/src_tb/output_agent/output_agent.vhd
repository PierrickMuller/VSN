--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : output_agent.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The agent responsible to observe the Morse code output.
--               It simply instanciates a monitor.
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

use work.transactions_pkg.all;

entity output_agent is
    generic (
        FIFOSIZE : integer := 8;
        TESTCASE : integer := 0;
        procedure blocking_put(variable output_transaction : in output_transaction_t)
        );
    port (
        signal clk_i         : in  std_logic;
        signal rst_i         : in  std_logic;
        signal port_output_i : in  std_logic;
        signal dot_period    : in  integer
        );
end output_agent;

architecture testbench of output_agent is

begin

    output_agent_monitor : entity work.output_agent_monitor
        generic map(
            FIFOSIZE     => FIFOSIZE,
            blocking_put => blocking_put
            )
        port map(
            clk_i,
            rst_i,
            port_output_i,
            dot_period);

end testbench;

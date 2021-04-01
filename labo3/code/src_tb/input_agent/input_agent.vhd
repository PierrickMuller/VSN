--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : input_agent.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The agent responsible to control the Morse burst emitter.
--               It simply instanciates a sequencer, a driver and a monitor.
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


entity input_agent is

    generic (
        FIFOSIZE : integer := 8;
        TESTCASE : integer := 0;
        procedure blocking_put(variable input_transaction : input_transaction_t)
        );

    port (
        clk_i         : in  std_logic;
        rst_i         : in  std_logic;
        port_input_o  : out morse_burst_emitter_control_in_t;
        port_output_i : in  morse_burst_emitter_control_out_t;
        dot_period    : out integer
        );

end input_agent;

architecture testbench of input_agent is

    -- Create a specialized FIFO package with the same data width for holding
    -- the transaction (requests and responses) they are of the same type.
    -- Very important: Use the specialized subtypes, not the generic ones
    package input_transaction_pkg is new tlm_fifo_pkg
    generic map (element_type => input_transaction_t,
                 nb_max_data  => 1);

    shared variable fifo_seq0_to_driver0 : input_transaction_pkg.tlm_fifo_type;

    procedure blocking_get_input_agent_driver(variable input_transaction : out input_transaction_t) is
    begin
        input_transaction_pkg.blocking_get(fifo_seq0_to_driver0, input_transaction);
    end blocking_get_input_agent_driver;

    procedure blocking_put_input_agent_sequencer(variable input_transaction : in input_transaction_t) is
    begin
        input_transaction_pkg.blocking_put(fifo_seq0_to_driver0, input_transaction);
        -- Here we send the transaction to the scoreboard
        if input_transaction.command /= send then
            blocking_put(input_transaction);
        end if;
    end blocking_put_input_agent_sequencer;

    signal port_input_s : morse_burst_emitter_control_in_t;

    procedure blocking_put_internal(variable input_transaction : input_transaction_t) is
    begin
        -- Yep, the monitor does not send the transaction to the scoreboard, the sequencer does.
        -- blocking_put(input_transaction);
    end blocking_put_internal;

begin

    port_input_o <= port_input_s;

    input_agent_sequencer : entity work.input_agent_sequencer
        generic map(FIFOSIZE     => FIFOSIZE,
                    TESTCASE     => TESTCASE,
                    blocking_put => blocking_put_input_agent_sequencer);

    input_agent_driver : entity work.input_agent_driver
        generic map(
            FIFOSIZE     => FIFOSIZE,
            blocking_get => blocking_get_input_agent_driver)
        port map(clk_i,
                 rst_i,
                 port_input_s,
                 port_output_i);

    input_agent_monitor : entity work.input_agent_monitor
        generic map(
            FIFOSIZE     => FIFOSIZE,
            blocking_put => blocking_put_internal)
        port map(clk_i,
                 rst_i,
                 port_input_s,
                 port_output_i,
                 dot_period);


end testbench;

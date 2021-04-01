--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : morse_burst_emitter_tb.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The top testbench of Morse burst emitter.
--               It instanciates the DUV, the two agents, the scoreboard,
--               and connect all these modules thanks to TLMVM FIFOs.
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

library morse;
use morse.morse_burst_emitter_pkg.all;

use work.transactions_pkg.all;

entity morse_burst_emitter_tb is
    generic (
        FIFOSIZE : integer := 8;
        ERRNO    : integer := 0;
        TESTCASE : integer := 0
        );
end morse_burst_emitter_tb;

architecture testbench of morse_burst_emitter_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk_sti     : std_logic;
    signal rst_sti     : std_logic;
    signal control_sti : morse_burst_emitter_control_in_t;
    signal control_obs : morse_burst_emitter_control_out_t;
    signal morse_obs   : std_logic;

    signal dot_period  : integer;

    component morse_burst_emitter is
        generic (
            FIFOSIZE   : integer := 16;
            ERRNO      : integer := 0
        );
        port (
            clk_i     : in std_logic;
            rst_i     : in std_logic;
            control_i : in morse_burst_emitter_control_in_t;
            control_o : out morse_burst_emitter_control_out_t;
            morse_o   : out std_logic
        );
    end component;

    -- Create a specialized FIFO package with the same data width for holding
    -- the transaction (requests and responses) they are of the same type.
    -- Very importan: Use the specialized subtypes, not the generic ones
    package input_transaction_pkg is new tlm_unbounded_fifo_pkg
    generic map (element_type => input_transaction_t);


    package output_transaction_fifo_pkg is new tlm_unbounded_fifo_pkg
    generic map (element_type => output_transaction_t);

    shared variable fifo_mon0_to_score : input_transaction_pkg.tlm_fifo_type;
    shared variable fifo_mon1_to_score : output_transaction_fifo_pkg.tlm_fifo_type;

    procedure blocking_put_agent0_monitor(variable input_transaction : in input_transaction_t) is
    begin
        input_transaction_pkg.blocking_put(fifo_mon0_to_score, input_transaction);
    end blocking_put_agent0_monitor;

    procedure blocking_put_agent1_monitor(variable output_transaction : in output_transaction_t) is
    begin
        output_transaction_fifo_pkg.blocking_put(fifo_mon1_to_score, output_transaction);
    end blocking_put_agent1_monitor;

    procedure blocking_get_input(variable input_transaction : out input_transaction_t) is
    begin
        input_transaction_pkg.blocking_get(fifo_mon0_to_score, input_transaction);
    end blocking_get_input;

    procedure blocking_get_output(variable output_transaction : out output_transaction_t) is
    begin
        output_transaction_fifo_pkg.blocking_get(fifo_mon1_to_score, output_transaction);
    end blocking_get_output;

    procedure rep(finish_status: finish_status_t) is
    begin
        if not fifo_mon0_to_score.is_empty then
            logger.error("Some transaction have not been received on the output" & LF & 
            "There remain " & integer'image(fifo_mon0_to_score.nb_data_available) & 
            " transactions in the scoreboard in FIFO.");
        end if;
        if finish_status = NO_BEAT then 
            logger.error("Simulation ending because of no more heart beats. The system seems dead.");
            if not no_objection then 
                logger.error("There are still objections");
            end if;
        end if;

        logger.final_report;
    end rep;

begin

    proc_init: process is
    begin
        logger.set_verbosity(note);
        wait;
    end process;

    monitor : simulation_monitor
        generic map (drain_time      => 50000 ns,
                     beat_time       => 160000 ns,
                     final_reporting => rep);

    clk_proc : clock_generator(clk_sti, CLK_PERIOD);

    rst_proc : simple_startup_reset(rst_sti, 2*CLK_PERIOD);

    input_agent : entity work.input_agent
        generic map(FIFOSIZE     => FIFOSIZE,
                    TESTCASE     => TESTCASE,
                    blocking_put => blocking_put_agent0_monitor)
        port map(clk_i         => clk_sti,
                 rst_i         => rst_sti,
                 port_input_o  => control_sti,
                 port_output_i => control_obs,
                 dot_period    => dot_period);

    output_agent : entity work.output_agent
        generic map(
            FIFOSIZE     => FIFOSIZE,
            TESTCASE     => TESTCASE,
            blocking_put => blocking_put_agent1_monitor
            )
        port map (clk_i         => clk_sti,
                  rst_i         => rst_sti,
                  port_output_i => morse_obs,
                  dot_period    => dot_period);

    scoreboard_inst : entity work.scoreboard
        generic map(
            FIFOSIZE            => FIFOSIZE,
            TESTCASE            => TESTCASE,
            blocking_get_input  => blocking_get_input,
            blocking_get_output => blocking_get_output
            );

    duv : morse_burst_emitter
        generic map (
            FIFOSIZE => FIFOSIZE
        )
        port map (
            clk_i     => clk_sti,
            rst_i     => rst_sti,
            control_i => control_sti,
            control_o => control_obs,
            morse_o   => morse_obs
            );

end testbench;

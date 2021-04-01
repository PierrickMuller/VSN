--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : input_agent_sequencer.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : The sequencer responsible for generating scenarios.
--               It generates transactions that can be sent to the driver
--               and potentially the scoreboard.
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

entity input_agent_sequencer is
    generic (
        FIFOSIZE                                          : integer := 8;
        TESTCASE                                          : integer := 0;
        procedure blocking_put(variable input_transaction : input_transaction_t)
    );
end input_agent_sequencer;

architecture testbench of input_agent_sequencer is

    procedure testcase1 is
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;

        -- loading character A
        transaction.char         := std_logic_vector(to_unsigned(65, 8));
        transaction.waiting_time := 0;
        transaction.command      := add_char;
        blocking_put(transaction);
        logger.note("Sequencer : Sent transaction number " & integer'image(counter));
        counter := counter + 1;

        -- Sends the character with a dot period of 5
        transaction.char         := (others => '0');
        transaction.waiting_time := 0;
        transaction.command      := send;
        transaction.dot_period   := std_logic_vector(to_unsigned(5, 28));
        blocking_put(transaction);
        logger.note("Sequencer : Sent transaction number " & integer'image(counter));
        counter := counter + 1;

    end testcase1;

    procedure testcase2 is
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;

        -- Sending all numbers from 0 to 9
        for i in 0 to 9 loop
            transaction.char         := std_logic_vector(to_unsigned(48 + i, 8));
            transaction.waiting_time := 0;
            transaction.command      := add_char;
            blocking_put(transaction);
            logger.note("Sequencer : Sent transaction number " & integer'image(counter));
            counter := counter + 1;

            transaction.char         := (others => '0');
            transaction.waiting_time := 0;
            transaction.command      := send;
            transaction.dot_period   := std_logic_vector(to_unsigned(5, 28));
            blocking_put(transaction);
            logger.note("Sequencer : Sent transaction number " & integer'image(counter));
            counter := counter + 1;
        end loop;
    end testcase2;
begin

    process is
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        -- Waits for the logger initialization
        wait for resolution_limit;
        raise_objection;
        counter := 0;

        case TESTCASE is
            when 0 =>
                testcase1;
                testcase2;

            when 1 =>
                testcase1;

            when 2 =>
                testcase2;

            when others =>
                logger.error("Sequencer : Unsupported testcase");
        end case;

        drop_objection;
        logger.note("Sequencer finished his job");
        wait;
    end process;
end testbench;
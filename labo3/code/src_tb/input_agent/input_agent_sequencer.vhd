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


    procedure sendTransaction(
            valid            : boolean;
            charValue        : integer;
            waitingTime      : integer;
            command          : command_t;
            dot_period       : integer;
            countTransaction : inout integer) is 
        variable transaction : input_transaction_t;
    begin
        transaction.valid        := valid;
        transaction.dot_period   := std_logic_vector(to_unsigned(dot_period, 28));
        transaction.char         := std_logic_vector(to_unsigned(charValue, 8));
        transaction.waiting_time := waitingTime;
        transaction.command      := command;
        blocking_put(transaction);
        logger.note("Sequencer : Sent transaction number " & integer'image(countTransaction));
        countTransaction := countTransaction + 1;
    end sendTransaction;


    -- HELLO WORLD (No burst)
    procedure testcase1 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;

        -- H  
        sendTransaction(true,72,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- E 
        sendTransaction(true,69,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- L * 2  
        for i in 0 to 1 loop 
            sendTransaction(true,76,0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        end loop;

        -- O 
        sendTransaction(true,79,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);
        
        -- SPACE 
        sendTransaction(true,32,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- W 
        sendTransaction(true,87,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- O 
        sendTransaction(true,79,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);
        
        -- R
        sendTransaction(true,82,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- L 
        sendTransaction(true,76,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- D
        sendTransaction(true,68,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

    end testcase1;

    -- Alphabet test (No burst)
    procedure testcase2 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;
        for i in 0 to 25 loop 
            sendTransaction(true,(65 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
            sendTransaction(true,(97 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        end loop;
    end testcase2;

    -- numbers 0-9 test (No burst)
    procedure testcase3 is
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;

        -- Sending all numbers from 0 to 9
        for i in 0 to 9 loop
            sendTransaction(true,(48 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        end loop;
    end testcase3;

    -- HELLO WORLD (burst and fifo FULL)
    procedure testcase4 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 11) then
            transaction.valid      := true;
            transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
            
            counter := 0;

            -- H  
            sendTransaction(true,72,0,add_char,5,counter);

            -- E 
            sendTransaction(true,69,0,add_char,5,counter);

            -- L * 2  
            for i in 0 to 1 loop 
                sendTransaction(true,76,0,add_char,5,counter);
            end loop;

            -- O 
            sendTransaction(true,79,0,add_char,5,counter);
            
            -- SPACE 
            sendTransaction(true,32,0,add_char,5,counter);

            -- W 
            sendTransaction(true,87,0,add_char,5,counter);

            -- O 
            sendTransaction(true,79,0,add_char,5,counter);
            
            -- R
            sendTransaction(true,82,0,add_char,5,counter);

            -- L 
            sendTransaction(true,76,0,add_char,5,counter);

            -- D
            sendTransaction(true,68,0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        else 
            logger.error("Testcase 4 : Fifo size must be equal or bigger than 11");
        end if;
    end testcase4;

    -- Alphabet test (burst and fifo FULL)
    procedure testcase5 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 52) then
            transaction.valid      := true;
            transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
            
            counter := 0;
            for i in 0 to 25 loop 
                sendTransaction(true,(65 + i),0,add_char,5,counter);
                sendTransaction(true,(97 + i),0,add_char,5,counter);
            end loop;
            sendTransaction(true,0,0,send,5,counter);
        else 
            logger.error("Testcase 5 : Fifo size must be equal or bigger than 26");
        end if;
    end testcase5;

    -- numbers 0-9 test (burst and fifo FULL)
    procedure testcase6 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 10) then
            transaction.valid      := true;
            transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
            
            counter := 0;
            -- Sending all numbers from 0 to 9
            for i in 0 to 9 loop
                sendTransaction(true,(48 + i),0,add_char,5,counter);
            end loop;
            sendTransaction(true,0,0,send,5,counter);
        else 
            logger.error("Testcase 6 : Fifo size must be equal or bigger than 10");
        end if;
    end testcase6;

    -- HELLO WORLD (burst and fifo filled during transfert)
    procedure testcase7 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;

        -- H  
        sendTransaction(true,72,0,add_char,5,counter);
        sendTransaction(true,0,0,send,5,counter);

        -- E 
        sendTransaction(true,69,0,add_char,5,counter);

        -- L * 2  
        for i in 0 to 1 loop 
            sendTransaction(true,76,0,add_char,5,counter);
        end loop;

        -- O 
        sendTransaction(true,79,0,add_char,5,counter);
        
        -- SPACE 
        sendTransaction(true,32,0,add_char,5,counter);

        -- W 
        sendTransaction(true,87,0,add_char,5,counter);

        -- O 
        sendTransaction(true,79,0,add_char,5,counter);
        
        -- R
        sendTransaction(true,82,0,add_char,5,counter);

        -- L 
        sendTransaction(true,76,0,add_char,5,counter);

        -- D
        sendTransaction(true,68,0,add_char,5,counter);
        

    end testcase7;
    
    -- Alphabet test (burst and fifo filled during transfert)
    procedure testcase8 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;
        for i in 0 to 25 loop 
            sendTransaction(true,(65 + i),0,add_char,5,counter);
            sendTransaction(true,(97 + i),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
        end loop;
    end testcase8;

    -- numbers 0-9 test (burst and fifo filled during transfert)
    procedure testcase9 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;
        -- Sending all numbers from 0 to 9
        for i in 0 to 9 loop
            sendTransaction(true,(48 + i),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
        end loop;
    end testcase9;

    -- Test 1000 char
    procedure testcase10 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin 
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;
        for i in 0 to 999 loop
            -- Random number beetween 0 and 25
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(25)));
            sendTransaction(true,(65 + int_rand_v),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
        end loop;
    end testcase10;

    -- Test not valid char (Don't work)
    procedure testcase11 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin 
        transaction.valid      := FALSE;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;
        for i in 0 to 9 loop
            sendTransaction(false,(1 + i),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(false,0,0,send,5,counter);
            end if;
        end loop;
    end testcase11;
    
    -- Test longer space
    procedure testcase12 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;
        for i in 0 to 99 loop
            -- Random number beetween 0 and 3
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(30)));
            sendTransaction(true,65,0,add_char,5,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
            sendTransaction(true,32,int_rand_v,add_char,5,counter);
        end loop;
    end testcase12;

    -- Test modification dot period
    procedure testcase13 is
        variable transaction : input_transaction_t;
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
        variable dot_period_v : integer;
    begin 
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        dot_period_v := 5;
        counter := 0;
        for i in 0 to 99 loop
            -- Random number beetween 0 and 25
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(25)));
            sendTransaction(true,(65 + int_rand_v),0,add_char,dot_period_v,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
            dot_period_v := i+1;
        end loop;


    end testcase13;

    -- Test word size 
    procedure testcase14 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin 
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));

        counter := 0;
        for i in 0 to 1000 loop
            for y in 0 to i loop
                -- Random number beetween 0 and 25
                UNIFORM(seed1_v,seed2_v,rand_v);
                int_rand_v := INTEGER(TRUNC(rand_v*real(25)));
                sendTransaction(true,(65 + int_rand_v),0,add_char,5,counter);
                if i = 0 and y = 0 then
                    sendTransaction(true,0,0,send,5,counter);
                end if;
            end loop;
            sendTransaction(true,32,0,add_char,5,counter);
        end loop;
    end testcase14;

    -- Test Fifo FULL et suppression de caractères (Not working correctly)
    procedure testcase15 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;
    begin
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        
        counter := 0;
        for i in 0 to 9 loop
            
            if i < FIFOSIZE then
                sendTransaction(true,(48 + i),0,add_char,5,counter);
            else 
                sendTransaction(false,(48 + i),0,add_char,5,counter);
            end if;
        end loop;
        sendTransaction(true,0,0,send,5,counter);
    end testcase15;

    -- Test random char, dot_period and space waiting time
    procedure testcase16 is 
        variable transaction : input_transaction_t;
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
        variable rand_char_v : integer;
        variable dot_period_v : integer;
    begin 
        transaction.valid      := true;
        transaction.dot_period := std_logic_vector(to_unsigned(5, 28));
        dot_period_v := 0;


        counter := 0;
        for i in 0 to 9999 loop
            -- Get number of char between 1 and 10 ( 0 and 9 but with the loop it's between 1 and 5) 
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(9)));
            for y in 0 to int_rand_v loop
                -- Get random Char
                UNIFORM(seed1_v,seed2_v,rand_v);
                rand_char_v := 65 + INTEGER(TRUNC(rand_v*real(25)));

                -- Get Random dot_period between 0 and 1000
                UNIFORM(seed1_v,seed2_v,rand_v);
                dot_period_v := INTEGER(TRUNC(rand_v*real(100)));

                -- send transaction
                sendTransaction(true,rand_char_v,0,add_char,dot_period_v,counter);

                if i = 0 and y = 0 then
                    sendTransaction(true,0,0,send,5,counter);
                end if;
            end loop;
        
            -- Get random waiting time for space between 0 and 1000
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(100)));

            sendTransaction(true,32,int_rand_v,add_char,dot_period_v,counter);
        end loop;
    end testcase16;


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
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase2;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase3;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase4;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase5;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase6;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase7;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase8;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase9;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase10;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase11;
                --sendTransaction(true,32,0,add_char,5,counter);
                --sendTransaction(true,0,0,send,5,counter);
                testcase12;
                sendTransaction(true,0,0,send,5,counter);
                testcase13;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase14;
                sendTransaction(true,0,0,send,5,counter);
                testcase15;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase16;

            when 1 =>
                testcase1;
            when 2 =>
                testcase2;
            when 3 => 
                testcase3;
            when 4 => 
                testcase4;
            when 5 =>
                testcase5;
            when 6 => 
                testcase6;
            when 7 => 
                testcase7;
            when 8 =>
                testcase8;
            when 9 => 
                testcase9;
            when 10 => 
                testcase10;
            when 11 => 
                testcase11;
            when 12 => 
                testcase12;
            when 13 => 
                testcase13;
            when 14 => 
                testcase14;
            when 15 => 
                testcase15;
            when 16 => 
                testcase16;
            when others =>
                logger.error("Sequencer : Unsupported testcase");
        end case;

        drop_objection;
        logger.note("Sequencer finished his job");
        wait;
    end process;
end testbench;
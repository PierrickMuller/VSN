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
-- 0.2   14.04.2021  PM         Add testcase for labo 3
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


    -- This procedure is used to simplify the send of a transaction to
    -- the driver. It is not a procedure that start a transaction, it put
    -- the transaction on the fifo.
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
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the sentence "hello world". Each character are 
    -- put in the fifo and immediatly send.
    procedure testcase1 is 
        variable counter     : integer;
    begin
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

    -- ALPHABET TEST (No burst)
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the alphabet lower/upper case. Each character are 
    -- put in the fifo and immediatly send.
    procedure testcase2 is 
        variable counter     : integer;
    begin
        counter := 0;
        -- All character (a/A to z/Z)
        for i in 0 to 25 loop 
            -- Send upper case 
            sendTransaction(true,(65 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
            -- Send lower case
            sendTransaction(true,(97 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        end loop;
    end testcase2;

    -- numbers 0-9 test (No burst)
    -- Author : Pierrick Muller
    --
    -- This testcase send each number o to 9. Each number are 
    -- put in the fifo and immediatly send.
    procedure testcase3 is
        variable counter     : integer;
    begin
        counter := 0;

        -- All numbers (0 to 9)
        for i in 0 to 9 loop
            -- Send number
            sendTransaction(true,(48 + i),0,add_char,5,counter);
            sendTransaction(true,0,0,send,5,counter);
        end loop;
    end testcase3;

    -- HELLO WORLD (burst and fifo FULL)
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the sentence "hello world". Each character are 
    -- put in the fifo and the send command is send only want all the character have been
    -- put in the fifo. If FIFOSIZE is not big enough to store all character, an error 
    -- is generated
    procedure testcase4 is 
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 11) then
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

    -- ALPHABET TEST (burst and fifo FULL)
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the alphabet lower/upper case. Each character are 
    -- put in the fifo and the send command is send only want all the character have been
    -- put in the fifo. If FIFOSIZE is not big enough to store all character, an error 
    -- is generated
    procedure testcase5 is 
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 52) then
            counter := 0;
            -- All character (a/A to z/Z)
            for i in 0 to 25 loop 
                -- Upper case
                sendTransaction(true,(65 + i),0,add_char,5,counter);
                -- Lower case
                sendTransaction(true,(97 + i),0,add_char,5,counter);
            end loop;
            -- Send command send
            sendTransaction(true,0,0,send,5,counter);
        else 
            logger.error("Testcase 5 : Fifo size must be equal or bigger than 26");
        end if;
    end testcase5;

    -- numbers 0-9 test (burst and fifo FULL)
    -- Author : Pierrick Muller
    --
    -- This testcase send each number o to 9. Each number are 
    -- put in the fifo and the send command is send only want all the character have been
    -- put in the fifo. If FIFOSIZE is not big enough to store all number, an error 
    -- is generated
    procedure testcase6 is 
        variable counter     : integer;
    begin
        if (FIFOSIZE >= 10) then
            counter := 0;
            -- All numbers (0 to 9)
            for i in 0 to 9 loop
                sendTransaction(true,(48 + i),0,add_char,5,counter);
            end loop;
            -- send command send
            sendTransaction(true,0,0,send,5,counter);
        else 
            logger.error("Testcase 6 : Fifo size must be equal or bigger than 10");
        end if;
    end testcase6;

    -- HELLO WORLD (burst and fifo filled during transfert)
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the sentence "hello world". Once the first 
    -- character is put in the fifo, the send command is send. After that, all the characters
    -- are put in the fifo during the system transmission.
    procedure testcase7 is 
        variable counter     : integer;
    begin
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
    
    -- ALPHABET TEST (burst and fifo filled during transfert)
    -- Author : Pierrick Muller
    --
    -- This testcase send each character of the alphabet lower/upper case. Once the first 
    -- character is put in the fifo, the send command is send. After that, all the characters
    -- are put in the fifo during the system transmission.
    procedure testcase8 is 
        variable counter     : integer;
    begin
        counter := 0;
        -- All character (A/a to Z/z)
        for i in 0 to 25 loop 
            -- Upper case
            sendTransaction(true,(65 + i),0,add_char,5,counter);
            -- If first character, send command send
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
            -- Lower case
            sendTransaction(true,(97 + i),0,add_char,5,counter);
        end loop;
    end testcase8;

    -- numbers 0-9 test (burst and fifo filled during transfert)
    -- Author : Pierrick Muller
    --
    -- This testcase send each number o to 9. Once the first 
    -- number is put in the fifo, the send command is send. After that, all the number
    -- are put in the fifo during the system transmission.
    procedure testcase9 is 
        variable counter     : integer;
    begin
        counter := 0;
        -- Sending all numbers from 0 to 9
        for i in 0 to 9 loop
            sendTransaction(true,(48 + i),0,add_char,5,counter);
            -- If first number, send command send
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
        end loop;
    end testcase9;

    -- TEST 100 RANDOM CHAR
    -- Author : Pierrick Muller
    -- 
    -- This testcase will generate 100 random character and send them with 
    -- without space beetween. The dot_period will be 5. The full testcase 
    -- use a "burst and fifo not full" style flow,
    -- meaning the send transaction command is sent after the load 
    -- of the first char and that the other char are filled into the fifo after.
    procedure testcase10 is 
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin 

        counter := 0;
        for i in 0 to 99 loop
            -- Random number beetween 0 and 25
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(25)));
            sendTransaction(true,(65 + int_rand_v),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(true,0,0,send,5,counter);
            end if;
        end loop;
    end testcase10;

    -- TEST NOT VALID CHAR (Don't work as expected)
    -- Author : Pierrick Muller
    -- 
    -- Due to my system implementation, this testcase does not work as intended.
    -- The idea of this testcase was to be sure that no char were send trough
    -- the system if the character in question was not correct. The idea was to check on 
    -- the output manager if there was a result or not in the output. Unfortunately, the only 
    -- way to test this as a "good case" and not as an error one was to only get the result 
    -- of the ouptut on the scoreboard if a transaction is valid, other was the scoreboard
    -- would be blocked trying to get transaction from the output manager that doesn't exist.
    -- I let it here and it's used in the 0 testcase because it does not harm, but my system
    -- would have to be modified to have this testcase working as expected. 
    procedure testcase11 is 
        variable counter     : integer;
    begin 

        -- we send transactions that are not valid.
        counter := 0;
        for i in 0 to 9 loop
            sendTransaction(false,(1 + i),0,add_char,5,counter);
            if i = 0 then
                sendTransaction(false,0,0,send,5,counter);
            end if;
        end loop;
    end testcase11;
    
    -- TEST LONGER SPACE 
    -- Author : Pierrick Muller
    -- 
    -- This testcase let us test the fact that if the space time is bigger
    -- than 7 dot_period, we should take that as a space anyway.
    -- This testcase send the character 65 with a space after with random 
    -- waiting time 100 time. Waiting time can't be too long because
    -- the testbench will consider that there is no hearbeat at some time.
    -- we set the waiting time randomly each iteration between 0 and 30 clock
    -- cycle. The full testcase use a "burst and fifo not full" style flow,
    -- meaning the send transaction command is sent after the load 
    -- of the first char and that the other char are filled into the fifo after.
    procedure testcase12 is 
        variable counter     : integer;
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin
        counter := 0;
        for i in 0 to 99 loop
            -- Random number beetween 0 and 30 for waiting time
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(30)));
            -- send char 65
            sendTransaction(true,65,0,add_char,5,counter);
            if i = 0 then
                -- Send command for burst
                sendTransaction(true,0,0,send,5,counter);
            end if;
            -- Send space with random waiting time.
            sendTransaction(true,32,int_rand_v,add_char,5,counter);
        end loop;
    end testcase12;

    -- TEST MODIFICATION DOT PERIOD
    -- Author : Pierrick Muller
    --
    -- This testcase test that the system does not change the dot 
    -- value period during an on-going send. The base dot_period is
    -- set to 5, then we send the first transaction (random char are
    -- used) with this dot_period. Then, we execute 99 other transaction with 
    -- a dot_period between 1 to 100. If the dot period is modified by the system,
    -- the output manager will not be able to reconstitute the transaction.
    -- the full testcase use a "burst and fifo not full" style flow,
    -- meaning the send transaction command is sent after the load 
    -- of the first char and that the other char are filled into the fifo after.
    procedure testcase13 is
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
        variable dot_period_v : integer;
    begin 
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

    -- TEST WORD SIZE
    -- Author : Pierrick Muller
    -- 
    -- This testcase test that the system allow us to write words with 
    -- a size beetween 1 to 100, with one space between. the dot period 
    -- is fixed to 5, the space beetween words have no waiting time, 
    -- the full testcase use a "burst and fifo not full" style flow,
    -- meaning the send transaction command is sent after the load 
    -- of the first char and that the other char are filled into the fifo after.
    procedure testcase14 is 
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
    begin 

        counter := 0;
        -- loop for the words
        for i in 0 to 99 loop
            -- loop for number of character
            for y in 0 to i loop
                -- We generate a random character, and send the transaction
                UNIFORM(seed1_v,seed2_v,rand_v);
                int_rand_v := INTEGER(TRUNC(rand_v*real(25)));
                sendTransaction(true,(65 + int_rand_v),0,add_char,5,counter);

                -- If it's the first character, we use the send command
                if i = 0 and y = 0 then
                    sendTransaction(true,0,0,send,5,counter);
                end if;
            end loop;
            -- We send the space
            sendTransaction(true,32,0,add_char,5,counter);
        end loop;
    end testcase14;


    -- TEST RANDOM CHAR, DOT_PERIOD AND SPACE WAITING TIME
    -- Author : Pierrick Muller
    --
    -- This testcase test 1000 words, each with between 1 and 10 random
    -- characters, with a space between each words with a random waiting
    -- time between 0 and 100, and each characters sent got a variable 
    -- dot_period (The first dot period of the first character should be
    -- the one used by the system for all transactions). This testcase 
    -- use a "burst and fifo not full" style flow, meaning the send transaction 
    -- command is sent after the load of the first char and that the 
    -- other char are filled into the fifo after.
    procedure testcase15 is 
        variable counter     : integer;  
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;  
        variable rand_char_v : integer;
        variable dot_period_v : integer;
    begin 
   
        dot_period_v := 0;
        counter := 0;
        for i in 0 to 999 loop
            -- Get number of char between 1 and 10 ( 0 and 9 but with the loop it's between 1 and 10) 
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
        
            -- Get random waiting time for space between 0 and 100
            UNIFORM(seed1_v,seed2_v,rand_v);
            int_rand_v := INTEGER(TRUNC(rand_v*real(100)));
            
            -- Send space
            sendTransaction(true,32,int_rand_v,add_char,dot_period_v,counter);
        end loop;
    end testcase15;


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
                -- When launching all testcase, we have sometime 
                -- to send a space between testcase in function
                -- of the testcase architecture. Sometime it just
                -- need the command send. Sometime it need nothing.
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
                testcase12;
                sendTransaction(true,0,0,send,5,counter);
                testcase13;
                sendTransaction(true,32,0,add_char,5,counter);
                sendTransaction(true,0,0,send,5,counter);
                testcase14;
                sendTransaction(true,0,0,send,5,counter);
                testcase15;
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
            when others =>
                logger.error("Sequencer : Unsupported testcase");
        end case;

        drop_objection;
        logger.note("Sequencer finished his job");
        wait;
    end process;
end testbench;
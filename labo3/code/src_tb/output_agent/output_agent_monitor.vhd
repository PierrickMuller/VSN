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
-- 0.2   14.04.2021  PM         Add morse output transaction detection
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
        variable size_char_v  : morse_char_length_t;
        variable morse_val_v  : std_logic_vector(0 to 4);
        variable dot_period_v : integer;
    begin

        -- Waits for the logger initialization
        wait for resolution_limit;

        counter := 0;
        down_counter := 0; 

        loop
            logger.note("Monitor waiting for transaction number " & integer'image(counter));
            ok := false;

     
            up_counter   := 0;
            char_v.size  := 0;
            char_v.value := "-----";
            -- if first transaction of the system, we wait an additional clock cycle.
            if down_counter = 0 then 
                wait until rising_edge(clk);
            end if;
            -- We wait until transaction start or if a space is bigger than 7 * dot_period
            while port_output = '0' loop
                wait until rising_edge(clk);
            end loop;
            -- If first transaction, we set the dot period to the value at the begining of the 
            -- transaction, so that for other transaction we don't change the dot value and can
            -- detect if the system change the dot_period (Results would be wrong)
            if down_counter = 0 then 
                dot_period_v := dot_period;
            end if;
            raise_objection;

            -- If down counter is 7 dot_period_v or more, a space was send
            -- That's the basic value of char_v, so no need to convert
            if down_counter >= (7 * dot_period_v) then
                -- If the char is not an existing char, we generate an error
                morse_to_ascii_check(char_v, transaction.char, transaction.valid);
                if transaction.valid = '0' then
                    logger.error("Output Monitor : Error in transaction number " & integer'image(counter) & 
                    ". Output got an invalid series of dots and dashes. Observed: " & morse_char_to_string(char_v));
                end if;
                
                -- We put the space in the output fifo
                blocking_put(transaction);
                logger.note("Output Monitor received transaction number " & integer'image(counter) & LF &
                    "Value : " & integer'image(to_integer(unsigned(transaction.char))) & LF &
                    "Size : " & integer'image(char_v.size) & LF & 
                    "Char : " & morse_char_to_string(char_v));
                counter := counter + 1;
            end if;


            up_counter   := 0;
            down_counter := 0;
            size_char_v  := 0;
            morse_val_v  := (others => '-');
            
            -- This loop will look if a character can be 
            -- generated from what we observe on the output 
            -- of the system. If down_counter is bigger
            -- than a dot period, this means that 
            while down_counter <= dot_period_v loop
                -- We reset those value because we want to 
                -- detect dot and space between them
                down_counter := 0;
                up_counter := 0;

                -- If the port is up, then we increment up_counter to 
                -- know how much time
                while port_output = '1' loop
                    up_counter := up_counter + 1;
                    wait until rising_edge(clk);
                end loop;
                
                -- We check if the up time of port_output
                -- was for a dot, for a dash, or for something else
                -- and we set the bit of the character in function of
                -- that. For undefine, we use value X
                if up_counter = dot_period_v then
                    morse_val_v(size_char_v) := '0';
                    size_char_v := size_char_v + 1;
                elsif  up_counter = (dot_period_v * 3) then
                    morse_val_v(size_char_v) := '1';
                    size_char_v := size_char_v + 1;
                else
                    morse_val_v(size_char_v) := 'X';
                    size_char_v := size_char_v + 1;
                end if;
                
                -- We check that what we observe is a space between dash/dot.
                -- If it's not the case, we will get out of this loop
                while port_output = '0' and down_counter <= dot_period_v loop
                    down_counter := down_counter + 1;
                    wait until rising_edge(clk);
                end loop;
            end loop;

            -- We get the character that was send and check if it as a valid one.
            -- If it's not the case, we generate an error
            char_v := morse_char_t'(size_char_v, morse_val_v);
            morse_to_ascii_check(char_v, transaction.char, transaction.valid);

            if transaction.valid = '0' then
                logger.error("Output Monitor : Error in transaction number " & integer'image(counter) & 
                ". Output got an invalid series of dots and dashes. Observed: " & morse_char_to_string(char_v));
            end if;
            
            --We put the transaction on the fifo
            blocking_put(transaction);
            logger.note("Output Monitor received transaction number " & integer'image(counter) & LF &
                "Value : " & integer'image(to_integer(unsigned(transaction.char))) & LF &
                "Size : " & integer'image(char_v.size) & LF & 
                "Char : " & morse_char_to_string(char_v));
            counter := counter + 1;

            -- We check for space here because we want to be inside the objection
            -- so that no transactions are loose.
            while port_output = '0' and down_counter <= 7 * dot_period_v loop
                down_counter := down_counter + 1;
                wait until rising_edge(clk);
            end loop;

            drop_objection;
        end loop;
        wait;
    end process;

end testbench;
/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : scoreboard.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the scoreboard responsible to handle the
              input and output transactions and generate errors in case
              characters do not match.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

class Scoreboard;

    int testcase;
    
    Morse_fifo_t sequencer_to_scoreboard_fifo;
    Morse_receiver_output_fifo_t monitor_to_scoreboard_fifo;

    task run;
        automatic MorseTransaction morse_trans;
        automatic MorseReceiverOutputTrans out_trans;
        logic[7:0] ascii_in_result = 0;
        $display("Scoreboard : Start");


        while (1) begin
            // Get a transaction from the sequencer
            sequencer_to_scoreboard_fifo.get(morse_trans);
            if(morse_trans.valid == 1) begin 
                // Get a transaction from the output monitor
                monitor_to_scoreboard_fifo.get(out_trans);

                if (is_lowercase(morse_trans.ascii))
                    ascii_in_result = morse_trans.ascii - 32;
                else 
                    ascii_in_result = morse_trans.ascii;
                $display(" RESULT in: %d",ascii_in_result);
                $display(" RESULT out: %d  -> valid : %d",out_trans.ascii,out_trans.valid);
                if((!morse_trans.is_a_fake_trans && (ascii_in_result != out_trans.ascii)) || morse_trans.is_a_fake_trans && out_trans.valid) begin
                    $error("RESULTS ARE NOT THE SAME");
                end 

                // TODO : Handle every needed verification here, and also be sure it is
                //        a good idea to get transactions from both FIFOs everytime... Or not
            end
            
        end

        $display("Scoreboard : End");
    endtask : run

endclass : Scoreboard

`endif // SCOREBOARD_SV

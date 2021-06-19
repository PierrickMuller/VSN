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
            
            //Check if the input transaction was valid
            if(morse_trans.valid == 1) begin 
                // Get a transaction from the output monitor
                monitor_to_scoreboard_fifo.get(out_trans);
                
                // If there is an error with the dot period, there is an error
                if(out_trans.dot_period_error == 1)
                    $error("Dot period error");
                
                // lowercase conversion
                if (is_lowercase(morse_trans.ascii))
                    ascii_in_result = morse_trans.ascii - 32;
                else 
                    ascii_in_result = morse_trans.ascii;

                //If ascii from in and out don't correspond or if the in ascii value was wrond and not detected
                //by the monitor, there is an error
                if((!morse_trans.is_a_fake_trans && (ascii_in_result != out_trans.ascii)) || morse_trans.is_a_fake_trans && out_trans.valid) begin
                    $error("Results are not the same or input was fake and was not detected");
                    display_trans_error(morse_trans,out_trans);
                end 

            end
            
        end

        $display("Scoreboard : End");
    endtask : run

    // Displays a transaction status
    task display_trans_error(MorseTransaction in_trans,MorseReceiverOutputTrans out_trans);
        $display("In data : %b", in_trans.morse.value);
        $display("In size : %d", in_trans.morse.size);
        $display("In Morse : %s", morse_char_to_string(in_trans.morse));
        $display("In Morse : %s", ascii_to_string(in_trans.ascii));
        $display("Out Morse : %s", ascii_to_string(out_trans.ascii));
    endtask : display_trans_error

endclass : Scoreboard

`endif // SCOREBOARD_SV

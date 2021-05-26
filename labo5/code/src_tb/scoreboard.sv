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

        $display("Scoreboard : Start");


        while (1) begin
            // Get a transaction from the sequencer
            sequencer_to_scoreboard_fifo.get(morse_trans);

            // Get a transaction from the output monitor
            monitor_to_scoreboard_fifo.get(out_trans);

            // TODO : Handle every needed verification here, and also be sure it is
            //        a good idea to get transactions from both FIFOs everytime... Or not
        end

        $display("Scoreboard : End");
    endtask : run

endclass : Scoreboard

`endif // SCOREBOARD_SV

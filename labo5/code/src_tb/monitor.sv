/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : monitor.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the output monitor responsible for getting
              the DUV output, putting it in a transaction and sending it
              to the scoreboard.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef MONITOR_SV
`define MONITOR_SV


class Monitor;

    // The testcase has to be setup by the environment
    int testcase;
    
    // The virtual interface allowing to access the DUV outputs
    virtual morse_out_itf vif;

    // The FIFO to send output transactions to the scoreboard
    Morse_receiver_output_fifo_t monitor_to_scoreboard_fifo;

    // Task executing the monitor's job. Simply waits for the valid_o signal
    // of the DUV.
    task run;
        MorseReceiverOutputTrans trans = new;
        $display("Monitor : start");

        while (1) begin
            @(posedge vif.clk_i);
            trans.dot_period_error = vif.dot_period_error_o;
            if (vif.char_valid_o == 1'b1) begin
                // Retrieve an ASCII code and transmits that to the scoreboard
                trans.ascii = vif.char_o;
                trans.valid = !vif.unknown_o;
                $display("Monitor : Got a transaction");
                monitor_to_scoreboard_fifo.put(trans);
            end
            else if (vif.unknown_o == 1'b1) begin
                // Retrieve an ASCII code and transmits that to the scoreboard
                trans.valid = !vif.unknown_o;
                $display("Monitor : Got a transaction");
                monitor_to_scoreboard_fifo.put(trans);
            end
            


        end

    $display("Monitor : end");
    endtask : run

endclass : Monitor

`endif // MONITOR_SV

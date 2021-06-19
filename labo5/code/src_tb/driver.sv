/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : driver.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the driver responsible for getting transactions
              from the sequencer and for playing them. It sends Morse code
              on a serial line. It also forces the dot_period to be used by the
              DUV.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef DRIVER_SV
`define DRIVER_SV

class Driver;

    // The testcase currently running. Could be useful
    int testcase;

    // The FIFO of transactions, from the sequencer
    Morse_fifo_t sequencer_to_driver_fifo;

    // The virtual interface
    virtual morse_itf vif;

    // Used to store the current dot_period. When a space or CR has to be sent
    // it uses the previous send_dot_period instead of loading a new one.
    logic[27:0] send_dot_period;

    int old_dot_period;
    MorseTransaction old_trans;
    int first_char = 1;
    // This task drives a Morse character
    task drive_trans(MorseTransaction trans);


        int dot_period = 0;

        dot_period = trans.dot_period;
        vif.dot_period_i <= dot_period;
        
        // If it's a letter
        if(trans.morse.value !== 5'bZZZZZ) begin
            
            //If it's the note the first char and that the precedent char 
            // was not a space, we set the input to 0 for 3 dot_period (between words)
            if(!first_char && old_trans.morse.value !== 5'bzzzzz) begin 
                vif.morse_i <= 1'b0;
                for (int d = 0; d < 3 * dot_period; d++) begin
                    @(posedge vif.clk_i);
                end
            end
            
            //We iterate over all bit of the value of the transaction
            //and we wait for the correct ammount of time (dot or dash)
            foreach(trans.morse.value[i]) begin
                case (trans.morse.value[i])
                0:
                begin
                    vif.morse_i <= 1'b1;
                    for (int d = 0; d < 1 * dot_period; d++) begin
                        @(posedge vif.clk_i);
                    end
                end
                1:
                begin
                    vif.morse_i <= 1'b1;
                    for (int d = 0; d < 3 * dot_period; d++) begin
                        @(posedge vif.clk_i);
                    end
                end
                1'bZ:
                begin
                    $error("A wrong bit value was detected : Z");
                end 
                1'bX:
                begin 
                    break;
                end 
                default: $error("A wrong bit value was detected : ???");
                endcase

                // If it's not the last bit of the transaction, we wait 
                // for one dot_period (between dot/dash)
                if ( i < (trans.morse.size - 1)) begin 
                    vif.morse_i <= 1'b0;
                    for (int d = 0; d < 1 * dot_period; d++) begin
                        @(posedge vif.clk_i);
                    end
                end

            end
        // If it's a space OR a cariage return 
        end else begin 
            //Set the serial line to 0 for dot_period time
            vif.morse_i <= 1'b0;
            for (int d = 0; d < 7 * trans.dot_period; d++) begin
                    @(posedge vif.clk_i);
            end
            // If it's a CR, we wait for some more time
            if(trans.ascii == 13) begin 
                for(int d = 0; d <= trans.log_relative_margin * trans.dot_period;d++) begin
                    @(posedge vif.clk_i);
                    @(posedge vif.clk_i);
                    @(posedge vif.clk_i);
                end
            end 
        end
        old_trans = trans;
        first_char = 0;


    endtask

    // This task executes the driver task. Waits for transactions from the sequencer
    // and then sends it thanks to drive_trans().
    task run;
        automatic MorseTransaction trans;
        int cont = 1'b1;
        $display("Driver : start");

        vif.morse_i <= 0;
        // Arbitrary value to start with
        vif.dot_period_i <= 10;
        send_dot_period = 10;
        // Apply a Reset
        vif.rst_i <= 1;
        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        // Then waits two clock cycles
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        // The driver runs while there is something in the FIFO.
        // It implies the sequencer should be fast enough to fill the FIFO.
        // It is OK if the scoreboard is not blocked waiting for the output monitor.
        // Anyway if the scoreboard is blocked it means there is an issue with the
        // DUV and an error should be detected.
        while (1) begin
            if (sequencer_to_driver_fifo.try_get(trans)) begin
                //display_trans(trans);
                drive_trans(trans);
            end
            else begin
                break;
            end
        end

        // At the end we wait for a time corresponding to a final CR.
        for(int i = 0; i < 8 * send_dot_period; i++)
            @(posedge vif.clk_i);

        $display("Driver : end");
    endtask : run

    // Displays a transaction status
    task display_trans(MorseTransaction trans);
        $display("Drive data : %b", trans.morse.value);
        $display("Drive size : %d", trans.morse.size);
        $display("Drive Morse : %s", morse_char_to_string(trans.morse));
        $display("Drive Morse : %s", ascii_to_string(trans.ascii));
        $display("Drive ascii : %d", trans.ascii);
    endtask : display_trans


endclass : Driver



`endif // DRIVER_SV

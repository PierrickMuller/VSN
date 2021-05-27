/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : environment.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the environment that embeds the 
              sequencer, the driver, the output monitor and the scoreboard.
              It simply creates the components and connect the FIFOs.
              It is also responsible for starting the tasks, waiting for the
              end of the simulation and perform some final checks.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "interfaces.sv"

class Environment;

    // Set a default value to the testcase to then check if it has been setup
    int testcase = -1;

    // Set a default value to the testcase to then check if it has been setup
    int log_relative_margin = -1;

    // The components of the environment
    Sequencer  sequencer;
    Driver     driver;
    Monitor    monitor;
    Scoreboard scoreboard;

    // The DUV has two interfaces, here we declare the associated virtual interfaces
    virtual morse_itf     input_itf;
    virtual morse_out_itf output_itf;

    // Three FIFOs are required to allow communication within the environment
    Morse_fifo_t                 sequencer_to_driver_fifo;
    Morse_fifo_t                 sequencer_to_scoreboard_fifo;
    Morse_receiver_output_fifo_t monitor_to_scoreboard_fifo;

    task build;
        // Abort if the testcase has been setup
        if (testcase == -1) begin
            $display("The testcase is not set. Aborting.");
            $finish(1);
        end

        // Create the 3 FIFOs
        sequencer_to_driver_fifo     = new(10);
        sequencer_to_scoreboard_fifo = new(10);
        monitor_to_scoreboard_fifo   = new(100);

        // Create the components
        sequencer  = new;
        driver     = new;
        monitor    = new;
        scoreboard = new;

        // Set the testcase for each component
        sequencer.testcase = testcase;
        driver.testcase = testcase;
        monitor.testcase = testcase;
        scoreboard.testcase = testcase;

        // The sequencer needs this generic parameter
        sequencer.log_relative_margin = log_relative_margin;

        // Set the virtual interfaces of the driver and monitor
        driver.vif  = input_itf;
        monitor.vif = output_itf;

        // Connect the various FIFOs to their respective components
        sequencer.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.sequencer_to_driver_fifo    = sequencer_to_driver_fifo;

        sequencer.sequencer_to_scoreboard_fifo  = sequencer_to_scoreboard_fifo;
        scoreboard.sequencer_to_scoreboard_fifo = sequencer_to_scoreboard_fifo;

        monitor.monitor_to_scoreboard_fifo    = monitor_to_scoreboard_fifo;
        scoreboard.monitor_to_scoreboard_fifo = monitor_to_scoreboard_fifo;

    endtask : build

    task run;

        // Two options to end the tests:
        // 1. The driver ends
        // 2. The sequencer, the monitor and the scoreboard end (all of them)
        //
        // The join waits for the 3 to end, while the join any waits either on
        // the driver or all the three others
        fork
            driver.run();
            begin
                fork
                    sequencer.run();
                    monitor.run();
                    scoreboard.run();
                join;
            end
        join_any;

        // Last checks to see if something remains in FIFOs

        // First the FIFO from the sequencer to scoreboard
        if (sequencer_to_scoreboard_fifo.num() > 0) begin
            $error("There are %d input transactions that didn't end up with an output", sequencer_to_scoreboard_fifo.num());
        end

        // Then the FIFO from the output monitor to the scoreboard
        if (monitor_to_scoreboard_fifo.num() > 0) begin
            // Loop on all the elements. If an element is not a CR (Carriage Return)
            // Then we display it
            while (monitor_to_scoreboard_fifo.num() > 0) begin
                automatic MorseReceiverOutputTrans outtrans;
                monitor_to_scoreboard_fifo.get(outtrans);
                if (outtrans.ascii != 8'h0D) begin
                    // That's not a CR
                    $error("End of simulation, there is this letter in the output FIFO : ASCII %b, Letter %s", outtrans.ascii, ascii_to_string(outtrans.ascii));
                end
            end
        end

    endtask : run

endclass : Environment


`endif // ENVIRONMENT_SV

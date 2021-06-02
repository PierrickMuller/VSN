/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : sequencer.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the sequencer responsible to generate
              scenarios for each testcase.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef SEQUENCER_SV
`define SEQUENCER_SV

class Sequencer;

    // The testcase to be executed
    int testcase;

    // The LOG_RELATIVE_MARGIN, from the testbench generic parameter
    int log_relative_margin;
    
    // The FIFO from sequencer to driver
    Morse_fifo_t sequencer_to_driver_fifo;

    // The FIFO from sequencer to scoreboard
    Morse_fifo_t sequencer_to_scoreboard_fifo;

    // Sends the 26 letters, in alphabetical order, with no space
    task testcase_letters;
        automatic MorseTransaction packet;
        $display("Sequencer : start testcase_letters");

        for(int i = 0; i < 26; i++) begin
            packet = new;
            // This constraint on ascii defines exactly the character
            void'(packet.randomize() with{ascii == 65 + i; });
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            $display("Sequencer: I sent a letter : %s!!!!", ascii_to_string(packet.ascii));
        end
        //send space 
        packet = new;
        void'(packet.randomize() with{ascii == 32; });
        sequencer_to_driver_fifo.put(packet);
        sequencer_to_scoreboard_fifo.put(packet);

    endtask : testcase_letters

    // TODO : Add testcases

    // Task executed by the sequencer.
    // Depending on the testcase we run all the tests, or only a specific one
    task run;
        $display("Sequencer : start");
        case (testcase)
        0:begin
            testcase_letters;
        end
        1: testcase_letters;
        default: $error("Testcase %d not supported", testcase);
        endcase

        $display("Sequencer : end");
    endtask : run

endclass : Sequencer


`endif // SEQUENCER_SV

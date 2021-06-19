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

    // Value use to check if wrong values are catched
    logic[5:0] wrong_values[22] = {
        5'b00100,
        5'b00101,
        5'b00010,
        5'b01010,
        5'b00110,
        5'b01000,
        5'b01001,
        5'b01011,
        5'b01100,
        5'b01101,
        5'b01110,
        5'b10001,
        5'b10010,
        5'b10011,
        5'b10100,
        5'b10101,
        5'b10110,
        5'b10111,
        5'b11001,
        5'b11010,
        5'b11011,
        5'b11101
    };

    // Sends the 26 letters, in alphabetical order, with no space and dot_period = 5
    task testcase_letters;
        automatic MorseTransaction packet;
        $display("Sequencer : start testcase_letters");


        for(int i = 0; i < 26; i++) begin
            packet = new;
            // This constraint on ascii defines exactly the character
            void'(packet.randomize() with{ascii == 65 + i; dot_period == 5; });
            packet.log_relative_margin = log_relative_margin;
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            $display("Sequencer: I sent a letter : %s!!!!", ascii_to_string(packet.ascii));
        end
    endtask : testcase_letters

    // Send the 10 numbers, from 0 to 9, with no space 
    task testcase_numbers;
        automatic MorseTransaction packet;
        $display("Sequencer : start testcase_letters");


        for(int i = 0; i < 10; i++) begin
            packet = new;
            // This constraint on ascii defines exactly the character
            void'(packet.randomize() with{ascii == 48 + i; dot_period == 5; });
            packet.log_relative_margin = log_relative_margin;
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            $display("Sequencer: I sent a letter : %s!!!!", ascii_to_string(packet.ascii));
        end

    endtask : testcase_numbers
    

    // Use randomization and coverage to send a sequence of caracteres, space and CR
    // Until the coverage is full. A space or CR can't follow a space or CR.
    // all caracters have to appear 250 time before the coverage is done. The dot_period value
    // is a random number between 1 and 100.
    task testcase_valid_ascii;
        automatic MorseTransactionCorrectAscii packet;
        logic[7:0] past_val;
        int i;
        $display("Sequencer : start testcase_all_ascii");

        i = 0;
        past_val = 32;
        while(packet.cov_group.get_coverage() < 100) begin 
            packet = new;
            if(past_val == 32 || past_val == 13)
                void'(packet.randomize() with{ascii != 32; ascii != 13; });
            else
                void'(packet.randomize());
            past_val = packet.ascii;
            packet.log_relative_margin = log_relative_margin;
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            packet.cov_group.sample();
            $display("Sequencer: I sent a letter : %s!!!!",ascii_to_string(packet.ascii));
            i = i + 1;
        end
    endtask : testcase_valid_ascii

    // Send the 22 "wrong" caracters with no space. The champ "Is a fake trans" is set
    // To one so that the scoreboard can check that the result is not valid in the output
    task testcase_wrong_char_only;
        automatic MorseTransaction packet;
        $display("Sequencer : start testcase_wrong_char_only");

        for( int i = 0 ; i< 22; i++) begin
            packet = new;
            packet.dot_period = 1;
            packet.ascii = 0;
            packet.valid = 1;
            packet.morse.value = wrong_values[i];
            packet.morse.size = 5; 
            packet.log_relative_margin = log_relative_margin;
            packet.is_a_fake_trans = 1;
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            $display("Sequencer: I sent a letter : %s!!!!", ascii_to_string(packet.ascii));
        end 
        
    endtask : testcase_wrong_char_only
 

    // Use randomization and coverage to send a sequence of caracteres, space and CR
    // Until the coverage is full. A space or CR can't follow a space or CR. the dot_period value
    // is a random number between 1 and 2^14 and the coverage is full once one of the value
    // of the 8 "box" defined in the transactions are observed.
    task testcase_valid_dot_period;
        automatic MorseTransactionDotPeriodSpectrum packet;
        logic[7:0] past_val;
        int i;
        $display("Sequencer : start testcase_valid_dot_period");

        i = 0;
        past_val = 32;
        while(packet.cov_group.get_coverage() < 100) begin 
            packet = new;
            // This constraint on ascii defines exactly the character
            if(past_val == 32 || past_val == 13)
                void'(packet.randomize() with{ascii != 32; ascii != 13; });
            else
                void'(packet.randomize());
            past_val = packet.ascii;
            packet.log_relative_margin = log_relative_margin;
            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
            packet.cov_group.sample();
            $display("Sequencer: I sent a letter : %s!!!!",ascii_to_string(packet.ascii));
            i = i + 1;
        end
    endtask : testcase_valid_dot_period


    // Task executed by the sequencer.
    // Depending on the testcase we run all the tests, or only a specific one
    task run;
        $display("Sequencer : start");
        case (testcase)
        0:begin
            testcase_letters;
            testcase_numbers;
            testcase_valid_ascii;
            testcase_wrong_char_only;
            testcase_valid_dot_period;
        end
        1: testcase_letters;
        2: testcase_numbers;
        3: testcase_valid_ascii;
        4: testcase_wrong_char_only;
        5: testcase_valid_dot_period;
        default: $error("Testcase %d not supported", testcase);
        endcase

        $display("Sequencer : end");
    endtask : run

endclass : Sequencer


`endif // SEQUENCER_SV

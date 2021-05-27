/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : morse_char_receiver_tb.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the top testbench that instantiates the
              DUV, the interfaces and the environment, and connect them
              together.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`include "morse_sv_pkg.sv"
`include "transactions.sv"
`include "interfaces.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"


module morse_char_receiver_tb#(int LOG_RELATIVE_MARGIN = 0, int TESTCASE = 0, int ERRNO = 0);

    morse_itf input_itf();
    morse_out_itf output_itf();

    morse_char_receiver#(.LOG_RELATIVE_MARGIN(LOG_RELATIVE_MARGIN), .ERRNO(ERRNO)) duv(
        .clk_i(output_itf.clk_i),
        .rst_i(input_itf.rst_i),
        .char_o(output_itf.char_o),
        .char_valid_o(output_itf.char_valid_o),
        .unknown_o(output_itf.unknown_o),
        .dot_period_error_o(output_itf.dot_period_error_o),
        .morse_i(input_itf.morse_i),
        .dot_period_i(input_itf.dot_period_i)
    );

    // génération de l'horloge
    always #5 output_itf.clk_i = ~output_itf.clk_i;

    always #5 input_itf.clk_i = ~input_itf.clk_i;

    Environment env;


    initial begin
        env = new;

        env.input_itf = input_itf;
        env.output_itf = output_itf;
        env.testcase = TESTCASE;
        env.log_relative_margin = LOG_RELATIVE_MARGIN;
        env.build;
        env.run();
        $finish;
    end

endmodule

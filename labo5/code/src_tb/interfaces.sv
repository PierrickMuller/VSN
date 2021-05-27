/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : interfaces.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the DUV interfaces declarations.
              The dot period has been put in the input interface to ease the
              driver's job. Conceptually speaking it could be better on the
              output interface, but it would complicate the testbench.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/

`ifndef INTERFACES_SV
`define INTERFACES_SV

// Output interface, on which the monitor connects
interface morse_out_itf;
    logic clk_i = 0;
    logic rst_i;
    logic[7:0] char_o;
    logic char_valid_o;
    logic unknown_o;
    logic dot_period_error_o;
endinterface : morse_out_itf

// Input interface, used by the driver
interface morse_itf;
    logic clk_i = 0;
    logic rst_i;
    logic morse_i;
    logic[27:0] dot_period_i;
endinterface : morse_itf

`endif // INTERFACES_SV

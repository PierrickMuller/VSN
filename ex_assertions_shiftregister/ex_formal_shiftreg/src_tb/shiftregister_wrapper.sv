/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : counter_sv_wrapper.sv
Author   : Yann Thoma
Date     : 25.10.2017

Context  : Example of assertions usage for formal verification

********************************************************************************
Description : This module is a wrapper that binds the DUV with the
              module containing the assertions

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   25.10.2017  YTA        Initial version

*******************************************************************************/

module shiftregister_wrapper#(int DATASIZE = 8)(
    input logic clk_i,
    input logic rst_i,
    input logic[1:0] mode_i,
    input logic[DATASIZE-1:0] load_value_i,
    input logic ser_in_msb_i,
    input logic ser_in_lsb_i,
    output logic[DATASIZE-1:0] value_o
);

    // Instantiation of the DUV
    shiftregister#(DATASIZE) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv shiftregister_assertions#(DATASIZE) binded(.*);

endmodule

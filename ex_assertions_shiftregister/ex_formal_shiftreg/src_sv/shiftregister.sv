/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : shiftregister.sv
Author   : Yann Thoma
Date     : 03.11.2017

Context  : Example of assertions usage for formal verification

********************************************************************************
Description : A simple shift register. Action depends on the mode:
              00 => hold
              01 => shift left
              10 => shift right
              11 => load

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   03.11.2017  YTA        Initial version

*******************************************************************************/

module shiftregister#(int DATASIZE = 8)(
    input logic clk_i,
    input logic rst_i,
    input logic[1:0] mode_i,
    input logic[DATASIZE-1:0] load_value_i,
    input logic ser_in_msb_i,
    input logic ser_in_lsb_i,
    output logic[DATASIZE-1:0] value_o
);

    // internal signal
    logic[DATASIZE-1:0] reg_s;

    // synchronous process
    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i == 1) begin
            reg_s <= 0;
        end
        else begin
            if (mode_i == 2'b11)
                reg_s <= load_value_i;
            else if (mode_i == 2'b01)
                reg_s <= {reg_s[DATASIZE-2:0] , ser_in_lsb_i};
            else if (mode_i == 2'b10)
                reg_s <= {ser_in_msb_i , reg_s[DATASIZE-1 : 1]};
        end
    end

    // Combinational assignation of the output
    assign value_o = 0;

endmodule

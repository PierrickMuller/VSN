/*******************************************************************************
 HEIG-VD
 Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 School of Business and Engineering in Canton de Vaud
 ********************************************************************************
 REDS Institute
 Reconfigurable Embedded Digital Systems
 ********************************************************************************

 File     : shiftregister_assertions.sv
 Author   : Yann Thoma
 Date     : 03.11.2017

 Context  : Example of assertions usage for formal verification

 ********************************************************************************
 Description : This module contains assertions for verifying a simple shift
 register. The modes are:
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

module shiftregister_assertions
  #(int DATASIZE = 8)(input logic                clk_i,
                      input logic                rst_i,
                      input logic [1:0]          mode_i,
                      input logic [DATASIZE-1:0] load_value_i,
                      input logic                ser_in_msb_i,
                      input logic                ser_in_lsb_i,
                      input logic [DATASIZE-1:0] value_o
);

    // load operation
    assert_load2: assert property (@(posedge clk_i) disable iff (rst_i==1)
    // Fill here
    );

    // maintain operation
    assert_maintain: assert property (@(posedge clk_i) disable iff (rst_i==1)
    // Fill here
    );

    // shift right operation
    property prop_shift_right;
        @(posedge clk_i) disable iff (rst_i==1)
        // Fill here
    endproperty
    assert_shift_right: assert property (prop_shift_right);

   // shift left operation
    property prop_shift_left;
        @(posedge clk_i) disable iff (rst_i==1)
        // Fill here
    endproperty
    assert_shift_left: assert property (prop_shift_left);

endmodule

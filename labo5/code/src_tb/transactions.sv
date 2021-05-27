/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : transactions.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains the transactions that are used by the
              testbench. Specifically the input transaction representing
              a Morse code.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/


`ifndef TRANSACTIONS_SV
`define TRANSACTIONS_SV

import morse_pkg::*;

import morse_sv_pkg::*;


/******************************************************************************
  Input transaction
******************************************************************************/
class MorseTransaction;

    // TODO : I'm sure there is something to modify here

    // The ASCII character that has to be sent
    rand logic[7:0] ascii;

    morse_char_t morse;

    // In post-randomization we compute the Morse code to be sent, depending
    function void post_randomize();

        morse_char_or_unknown_t va;

        // Converts the ASCII to morse
        va = ascii_to_morse(ascii);
        morse = va.char;

    endfunction : post_randomize

endclass : MorseTransaction

class MorseReceiverOutputTrans;

    // TODO : I'm sure there is something to modify here

    logic[7:0] ascii;
    logic valid;

endclass : MorseReceiverOutputTrans


typedef mailbox #(MorseTransaction) Morse_fifo_t;

typedef mailbox #(MorseReceiverOutputTrans) Morse_receiver_output_fifo_t;

`endif // TRANSACTIONS_SV

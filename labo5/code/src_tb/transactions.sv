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

    rand int dot_period;

    morse_char_t morse;

    logic valid;
    logic is_a_fake_trans;

    constraint dot_period_value {
        dot_period >= 1;
        dot_period <= 100;
    }

    
    // In post-randomization we compute the Morse code to be sent, depending
    function void post_randomize();

        morse_char_or_unknown_t va;

        // Converts the ASCII to morse
        va = ascii_to_morse(ascii);
        //valid = 1;
        is_a_fake_trans = 0;
        valid = !va.unknown;
        morse = va.char;
        //dot_period = 2;
     
    endfunction : post_randomize

endclass : MorseTransaction

class MorseTransactionCorrectAscii extends MorseTransaction;

    rand int repetition;

    constraint correctValue {
        ascii inside{13,32,[48:57],[65:90],[97:122]};// || inside{[65:90]} || inside{[97:122]};
    }

    covergroup cov_group;
        cov_ascii: coverpoint ascii{
            option.at_least = 50;
            ignore_bins test = {[0:12],[14:47],[58:64],[91:96],[123:256]};
        }
    endgroup
    
    function new;
        cov_group=new;
    endfunction : new
endclass : MorseTransactionCorrectAscii //className extends superClass

class MorseReceiverOutputTrans;

    // TODO : I'm sure there is something to modify here

    logic[7:0] ascii;
    logic valid;

endclass : MorseReceiverOutputTrans


typedef mailbox #(MorseTransaction) Morse_fifo_t;

typedef mailbox #(MorseReceiverOutputTrans) Morse_receiver_output_fifo_t;

`endif // TRANSACTIONS_SV

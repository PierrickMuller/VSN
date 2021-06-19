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

    // VARIABLES
    rand logic[7:0] ascii;
    rand logic[28:0] dot_period;
    int log_relative_margin;
    morse_char_t morse;
    logic valid;
    logic is_a_fake_trans;
    
    // In post-randomization we compute the Morse code to be sent, depending
    function void post_randomize();

        morse_char_or_unknown_t va;

        // Converts the ASCII to morse
        va = ascii_to_morse(ascii);

        // Set default trans to real trans
        is_a_fake_trans = 0;

        // Set valid value 
        valid = !va.unknown;
        morse = va.char;
     
    endfunction : post_randomize

endclass : MorseTransaction

class MorseTransactionDotPeriodSpectrum extends MorseTransaction;

    // VARIABLE
    rand int multiple;

    // Constraint that check that the ascii value is a correct one
    constraint correctValue {
        ascii inside{13,32,[48:57],[65:90],[97:122]};
    }

    // Constraint that select one value in the box calculated in function of 
    // "multiple" variable
    constraint dot_period_value {

        dot_period inside{[((multiple * (2**(14-3))) + 1):((multiple+1)*(2**(14-3)))]};
    }
    
    //Constraint that select the box by assigning one value between 0 to 7 in multiple value
    constraint multiple_Value {
        multiple < 8;
        multiple >= 0;
    }

    // We want to resolve multiple before we resolve the dot_period 
    // that need the dot_period
    constraint order {solve multiple before dot_period;}

    // Covergroup that check that we have seen one value in each of the box that are size 2^(14-3) (2^3 boxs)
    covergroup cov_group;
        cov_dot: coverpoint dot_period{
            option.at_least = 1;
            bins separation[8] = {[1:2**14]};
        }
    endgroup
    
    function new;
        cov_group=new;
    endfunction : new
endclass : MorseTransactionDotPeriodSpectrum 

class MorseTransactionCorrectAscii extends MorseTransaction;

    // Constraint that check that the ascii value is a correct one
    constraint correctValue {
        ascii inside{13,32,[48:57],[65:90],[97:122]};
    }

    // Constraint that set dot_period to a value between 1 and 100
    constraint dot_period_value {
        dot_period >= 1;
        dot_period <= 100;
    }

    // Covergroup that check that we have seen at least 250 time each correct value.
    // we ignore ascii value that don't represent an morse value.
    covergroup cov_group;
        cov_ascii: coverpoint ascii{
            option.at_least = 250;
            ignore_bins test = {[0:12],[14:47],[58:64],[91:96],[123:256]};
        }
    endgroup
    
    function new;
        cov_group=new;
    endfunction : new
endclass : MorseTransactionCorrectAscii 

class MorseReceiverOutputTrans;

    logic[7:0] ascii;
    logic valid;
    logic dot_period_error;

endclass : MorseReceiverOutputTrans


typedef mailbox #(MorseTransaction) Morse_fifo_t;

typedef mailbox #(MorseReceiverOutputTrans) Morse_receiver_output_fifo_t;

`endif // TRANSACTIONS_SV

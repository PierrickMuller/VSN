/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : morse_sv_pkg.sv
Author   : Yann Thoma
Date     : 20.05.2021

Context  : Verification of a Morse code receiver

********************************************************************************
Description : This file contains a package offering various functions that
              are used throughout the testbench.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.05.2021  YTA        Initial version

*******************************************************************************/


`ifndef MORSE_SV_PKG_SV
`define MORSE_SV_PKG_SV


package morse_sv_pkg;

import morse_pkg::*;

    // Calculates the dot_period margin from a dot_period and a log_relative_margin.
    // Corresponds to the DUV's computation.
    function int get_margin(logic[27:0] dot_period, int log_relative_margin);
        if (log_relative_margin == 0)
            return 0;
        return dot_period >> log_relative_margin;
    endfunction

    // Calculates the min_dot_period from a dot_period and a log_relative_margin.
    // Corresponds to the DUV's computation.
    function int get_min_dot_period(logic[27:0] dot_period, int log_relative_margin);
        return dot_period - get_margin(dot_period, log_relative_margin);
    endfunction

    // Calculates the max_dot_period from a dot_period and a log_relative_margin.
    // Corresponds to the DUV's computation.
    function int get_max_dot_period(logic[27:0] dot_period, int log_relative_margin);
        return dot_period + get_margin(dot_period, log_relative_margin);
    endfunction
    
    // Converts an 8-bit vector representing an ASCII character to a string
    function string ascii_to_string(logic[7:0] ascii);
        automatic string result = "c";
        result.putc(0, ascii);
        return result;
    endfunction

    // Checks whether an ASCII character is an uppercase letter
    function is_uppercase(logic[7:0] ascii);
        return (ascii > 64) && (ascii < 91);
    endfunction

    // Checks whether an ASCII character is a lowercase letter
    function is_lowercase(logic[7:0] ascii);
        return (ascii > 96) && (ascii < 123);
    endfunction

    // Converts an ASCII character to lowercase
    function to_lowercase(logic[7:0] ascii);
        if (is_uppercase(ascii))
            return ascii + 32;
        return ascii;
    endfunction

    // Checks whether an ASCII character is a number or not
    function is_number(logic[7:0] ascii);
        return (ascii > 47) && (ascii < 58);
    endfunction

    // Converts an ASCII character to a Morse representation
    function morse_char_or_unknown_t ascii_to_morse(logic[7:0] ascii);
        logic[7:0] value_v ;
        morse_char_or_unknown_t result;
        value_v = ascii;
        if (value_v == 32 || value_v == 13) begin
            // This is a space, and will be interpreted as such
           // result = {0, {0, 5'bZZZZZ}};
            result.unknown = 0;
            result.char.value = 5'bZZZZZ;
            result.char.size = 0;
            end
        else if ((value_v > 64) && (value_v < 91)) begin
            result.unknown = 0;
            result.char = morse_pkg::letter_conversion_c[((ascii)) - 65];
        end
        else if ((value_v > 96) && (value_v < 123)) begin
            result.unknown = 0;
            result.char = morse_pkg::letter_conversion_c[((ascii)) - 97];
        end
        else if ((value_v > 47) && (value_v < 58)) begin
            result.unknown = 0;
            result.char = morse_pkg::number_conversion_c[((ascii)) - 48];
        end
        else begin
            result.unknown = 1;
            result.char.value = 5'bZZZZZ;
            result.char.size = 0;
        end
        return result;
    endfunction;

    // Converts a Morse character to ASCII and indicates if it was a valid Morse code or not
    task morse_to_ascii_check(morse_char_t morse, output logic[7:0] ch, output logic valid);
        automatic int result_v = 0;
        automatic logic valid_v = 1'b0;
        if (morse.size == 0) begin
            result_v = 32;
            valid_v = 1'b1;
        end
        else begin
            for (int i = 0; i < 10; i++) begin
                if (morse.size == number_conversion_c[i].size) begin
                    automatic int found = 1'b0;
                    for (int j = 0; j < number_conversion_c[i].size; j++) begin
                        found = found || (morse.value[j] == number_conversion_c[i].value[j]);
                    end
                    if (found) begin
                        result_v = 48 + i;
                        valid_v = 1'b1;
                    end
                end
            end
            for (int i = 0; i < 26; i++) begin
                if (morse.size == letter_conversion_c[i].size) begin
                    automatic int found = 1'b0;
                    for (int j = 0; j < letter_conversion_c[i].size; j++) begin
                        found = found || (morse.value[j] == letter_conversion_c[i].value[j]);
                    end
                    if (found) begin
                        result_v = 65 + i;
                        valid_v = 1'b1;
                    end
                end
            end
        end
        ch = result_v;
        valid = valid_v;
    endtask


    // Get the Morse representation of a Morse character
    function string morse_char_to_string(morse_char_t char_in);
        automatic string result_v;
        for (int i = 0; i < char_in.size; i++) begin
            if (char_in.value[i] == 1'b0)
                result_v = {result_v, "."};
            else
                result_v = {result_v, "-"};
            
        end
        return result_v;
    endfunction


endpackage

`endif // MORSE_SV_PKG_SV
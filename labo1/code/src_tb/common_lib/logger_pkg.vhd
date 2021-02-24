
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package logger_pkg is

    type logger_t is protected

        procedure log_error(message : string := "");

        procedure final_report;

        -- TODO : Complete

    end protected logger_t;

end logger_pkg;


package body logger_pkg is

    type logger_t is protected body

        variable nb_errors : integer := 0;

        procedure log_error(message: string := "") is
        begin
            report message severity error;
            nb_errors := nb_errors + 1;
            report "Nb errors = " & integer'image(nb_errors);
        end log_error;

        procedure final_report is
        begin
            -- TODO : Complete
        end final_report;

    end protected body logger_t;

end package body logger_pkg;

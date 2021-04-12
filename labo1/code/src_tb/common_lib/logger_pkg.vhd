library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package logger_pkg is

    type logger_t is protected

        procedure log_util(message_verbosity : severity_level; message : string := "");
        procedure log_note(message : string := "");
        procedure log_warning(message : string := "");
        procedure log_error(message : string := "");
        procedure log_failure(message : string := "");

        procedure define_verbosity(level : severity_level := note);
        procedure final_report;

        impure function init(name : string := "") return FILE_OPEN_STATUS;
        procedure write_string_to_file(message : string := "");

    end protected logger_t;

end logger_pkg;


package body logger_pkg is

    type logger_t is protected body
        
        --- VARIABLES
        variable nb_errors_v : integer := 0;
        variable nb_warnings_v : integer := 0; 
        variable verbosity_v : severity_level := note;
        variable line_v : Line;
        variable has_log_file_v : integer := 0; 
        variable fstatus_v : FILE_OPEN_STATUS;
        file fw_v: TEXT;

        --- PROCEDURES/FUNCTIONS 

        -- This procedure contain the logic behind the procedures log_*verbosity*
        procedure log_util(message_verbosity : severity_level; message : string := "") is
        begin 
            
            if message_verbosity = error then
                nb_errors_v := nb_errors_v + 1;
            end if;

            if message_verbosity = warning then
                nb_warnings_v := nb_warnings_v + 1;
            end if;

            if message_verbosity <= verbosity_v then 
                report message severity message_verbosity;
                write_string_to_file(string'(message));
                if message_verbosity = error then
                    report "Nb errors = " & integer'image(nb_errors_v) & LF;
                    write_string_to_file(string'("Nb errors = " & integer'image(nb_errors_v)) & LF);
                end if;
    
                if message_verbosity = warning then
                    report "Nb warnings = " & integer'image(nb_warnings_v) & LF;
                    write_string_to_file(string'("Nb warnings = " & integer'image(nb_warnings_v)) & LF);
                end if;
            end if;
        end log_util;
        
        -- Show a message with serverity-level NOTE
        procedure log_note(message: string := "") is 
        begin 
            log_util(note,message);
        end log_note;

        -- Show a message with serverity-level WARNING
        procedure log_warning(message: string := "") is 
        begin 
            log_util(warning,message);
        end log_warning;

        -- Show a message with serverity-level ERROR
        procedure log_error(message: string := "") is
        begin
            log_util(error,message);
        end log_error;

        -- Show a message with serverity-level FAILLURE
        procedure log_failure(message: string := "") is 
        begin 
            log_util(failure,message);
        end log_failure;
        
        -- Used to define verbosity [NOTE,WARNING,ERROR,FAILLURE]
        procedure define_verbosity(level : severity_level := note) is
        begin 
            verbosity_v := level;
        end define_verbosity;
        
        -- Show number of error and warning and handle the closing of the files (if there is a log file)
        procedure final_report is
        begin
            report "TOTAL ERRORS : " & integer'image(nb_errors_v);
            write_string_to_file(string'("TOTAL ERRORS : " & integer'image(nb_errors_v)));
            report "TOTAL WARNINGS : " & integer'image(nb_warnings_v);
            write_string_to_file(string'("TOTAL WARNINGS : " & integer'image(nb_warnings_v)));
            if has_log_file_v = 1 then 
                FILE_CLOSE(fw_v);
            end if;
        end final_report;

        -- Open à file and return the status. 
        impure function init(name : string := "") return FILE_OPEN_STATUS is 
        begin       
            FILE_OPEN(fstatus_v, fw_v, name, WRITE_MODE);
            if fstatus_v = OPEN_OK then 
                has_log_file_v := 1;
            end if;
            return fstatus_v;
        end init;
        
        -- Util : This procedure is used to easily write to the open log file
        procedure write_string_to_file(message : string := "") is 
        begin 
            if has_log_file_v = 1 then
                WRITE(line_v,string'(message));
                WRITELINE(fw_v,line_v);
            end if;
        end write_string_to_file;


    end protected body logger_t;

end package body logger_pkg;

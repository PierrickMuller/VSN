
library common_lib;
use common_lib.logger_pkg;

package comparator_pkg is
    generic(
        type data_type;
        function data_to_string(data : data_type) return string
    );

    procedure compare(logger : inout logger_pkg.logger_t; value1 : data_type; value2: data_type);

    function compare(value1 : data_type; value2: data_type) return boolean;

end comparator_pkg;

package body comparator_pkg is

    procedure compare(logger: inout logger_pkg.logger_t; value1 : data_type; value2: data_type) is
    begin
        
        -- Usage of compare function to show a message when values are not equal
        if compare(value1,value2) = false then 
            logger.log_error(string'("Simple compare : Both Values are not equal : " & LF &
                                     "Value 1 : " &  LF & data_to_string(value1) & LF & 
                                     "Value 2 : " &  LF & data_to_string(value2) & LF));
        end if;
    end compare;


    function compare(value1 : data_type; value2: data_type) return boolean is
    begin

        -- Simple comparison beetwen the two values
        if value1 = value2 then 
            return true;
        else 
            return false;
        end if;
    end compare;

end comparator_pkg;



library common_lib;
use common_lib.logger_pkg;

package complex_comparator_pkg is
    generic(
        type data_type;
        function data_to_string(data : data_type) return string;
        function complex_compare(data1 : data_type; data2 : data_type) return boolean
    );

    procedure compare(logger : inout logger_pkg.logger_t; value1 : data_type; value2: data_type);

end complex_comparator_pkg;

package body complex_comparator_pkg is

    procedure compare(logger: inout logger_pkg.logger_t; value1 : data_type; value2: data_type) is
    begin
        
        -- Usage of compare function to show a message when values are not equal (With custom function complex_compare)
        if complex_compare(value1,value2) = false then 
        logger.log_error(string'("Complex Compare : Both Values are not equal : " & LF & 
                                 "Value 1 : " &  LF & data_to_string(value1) & LF & 
                                 "Value 2 : " &  LF & data_to_string(value2) & LF));
        end if;
    end compare;

end complex_comparator_pkg;

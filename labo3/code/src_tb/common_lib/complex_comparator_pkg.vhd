

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

`protect begin_protected
`protect version = 1
`protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "2020.1_1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
isufb54ftKi2XtwAAtv0emO64jKrVseMG+wqxwFYKZxZkZ4AHDbmdB0D3qiz+fea
RmQdkFWdjfHhK/Aj1gZtbXiHRezwimxVRBgQjbKmlt34OolplSV6e2DSeXhpZ0I/
uMP+RsXU0ptmvpUXyBFbSUwYxZnTAW8xeIfAehDlhWDctEHZVck827eIVhNoLCkC
ASoz6BDSqoeiYLmP9oWxcibXPqjfGRYmteFHgLfYJqEEZfVv0fzOYWAMp55uvf6r
7crxLotjzjualFwaXAoGiqp+ogsd+BkrQz8ixA51ZWOZ0GQ0qoF6KXg590lBmwLX
ut2sKPjouuZXlr7wvRldPg==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 432 )
`protect data_block
IqqRRotGyN2xZ40oixolj3VgXuprlA9htkNV9U8IieX+xFMh2E9e9aZ2sTvhEM1t
ZROv+STBWdZlfvQCLEeO+jc/B20M9+leF6XY+pgSisqZOEluPwaIPMJnWl3YY+XN
Wm3MWn6iQggJnvIs77sgDnVEhg7abLNfzzhm169yiobKdw7LqE7nBS5zc5Wo1869
z99EtMQ9PbxkBOU+QlbSnVDFK1B3kKR1/2y42u0zA29WkRzSZ5E1eklyx2j+WZxh
Rv33Eizw65Aju7AgI2pQouNVMmSLckcI6xf2VbNjsPqd0vEW7DO/ZUb9iNHUnd7I
RTQuXYhjIHKU+lbYomrz8+aUjKTy1sZFxxHQGalg/v65HxMu19WhdT8aGEKzQOat
w+LiBoxxLY16nSIti318q4fgIhvfWy2xRNmTFWsHmLfzZeD3ndVRJpajQdE8RRS9
l5YPLOeeh9EGGb2GPRxfv5Q5CCf9wYg1AlwtOybfgz4stuP6vYK/oAnjnzvf2d7c
UwOD0vQvmSVP3bPCZfyjyixWmKKhZ2DizwvGRM/h75MXI0eopIbGTfUHozYY3HHr
`protect end_protected

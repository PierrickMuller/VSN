
library common_lib;
use common_lib.logger_pkg;

package comparator_pkg is
    generic(
        type data_type;
        function data_to_string(data : data_type) return string
    );

    procedure compare(logger : inout logger_pkg.logger_t; value1 : data_type; value2: data_type);

end comparator_pkg;

`protect begin_protected
`protect version = 1
`protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "2020.1_1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
X//+yPb7pyiaZriXRzpYB+Mhv5m1xeI9Rg07RbmI0PDLBOU3S3qAeKUejId4VAkM
3oQCXnIpuf3gaqyXnFjxrZXDKS73fDu17Nakgtvt/aNRiPaqDl18NzANthcdM/+K
JYIEMawl1Bly8ZJA+VG5dNGA4jtTi6nYLTxexpdjax8vtMlUXmmZ+llUu7UpvZkh
dXbpnJ9Kj3PCf10JHiatGfR575rcnTnZtuYad7XzjLiNFxUiwtq3q2caId4Fyj+q
XGyBzwfmQN1nL304YwWZ9Fj8DTB7fEYQWM+BykvRxv4AIJjCzuDoTMoCoer1I0od
xtM1wOYUib6+x5vwpVjZag==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 400 )
`protect data_block
I7kT54QDR9LjU56aMKcPl+fIA0lBYe6y38j2f4Nszy4AllBt11pjxirgXc2TmvSI
2WGzZOGSJyWfdvUPX8xum7KmBga/II9yS/5xulGXSP2Z4X617nWfJj7AMqJ1Ue2q
GnJp2XJazyolkYixuWZRzgH+jr6hyYJVaHFmwaO2q2BdqMIFRdfVfBh6ydu9n9Wc
4ELXM5CRImZkMMwBJkdxzIt/y0F/2tOlWj9f15yYfKV5Jxr4oPlvUsE6PDacwx57
d1M1ItxAh2cKbQmT52O+UfAbqDzefF8yL3Hl7lYFm5IrG4DIwg72jLAYWnQxfa+R
/h7i1TRSJEFr/nHOEGGCnrGRkLDey+hQgTsxPTGSJoVYGhfVXE3VPWBil4mj5bMG
fHuufK/U+SZ+I0JAiWx+0PTpgIKOd3OFItq/Y8tjFltt9JyNH2fQtsVcnIRQ2vuw
1H7S4F4tqWbxv7rYoCsdo0LfdFYFAD1w4IYugtTsbmQpGEx6f64wQ9WPzDjTR2gr
waVfSHhmxCycj7cyt8QcbQ==
`protect end_protected


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library morse;
use morse.morse_pkg.all;
use morse.morse_burst_emitter_pkg.all;

entity morse_burst_emitter is
    generic (
        FIFOSIZE : integer := 16;
        ERRNO    : integer := 0
    );
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;
        control_i : in morse_burst_emitter_control_in_t;
        control_o : out morse_burst_emitter_control_out_t;
        morse_o   : out std_logic
    );
end morse_burst_emitter;

`protect begin_protected
`protect version = 1
`protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "2020.1_1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
PE/A97GWL7wofjbilLCRIUIKqoaiFEzLmozd3KMX6LDJGJwoGjWi3qZWxHBfWIV1
6/W3TgJmRrJ4ob3ZesbeMPDzzzXT2ybHYkqgJoZu92L6UaZ86DFlaNnydSnEyqCi
as9el0Z6z9NtC7j8mn9wRcUbaG8VZQH2jtzpgOwYgP3vqQ73+9l5RndxNsRZggI6
12BPWEdabLtKh8vddk6VIaoKt9hnFeRt7l70wV2qTDGcYbcPx/P0MLjFvkuzw9Wa
4bv7u3pg4Q/GCifmfatbQlgUS0cc2X+GyFZvSP4/cAMCAdE1MVddZypD533vGHWw
Kv8IC4Il9Uh+Ahx46B80MQ==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 4080 )
`protect data_block
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
`protect end_protected

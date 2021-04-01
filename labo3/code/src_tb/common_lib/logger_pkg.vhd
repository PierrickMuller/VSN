-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : logger_pkg.vhd
-- Description  :
--
-- Author       : Mike Meury
-- Date         : 21.02.18
-- Version      : 0.0
--
-- Dependencies :
--
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 0.0       MIM    21.02.18           Creation
-- 0.1       YTA    22.02.18           Removed vector procedures and added
--                                     verbosity
-------------------------------------------------------------------------------

------------------------
-- Standard libraries --
------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------
-- Specifics libraries --
-------------------------
-- IO for files
use STD.textio.all;
use ieee.std_logic_textio.all;

------------------------
-- Package definition --
------------------------
package logger_pkg is

    -- This logger type allows to centralize all logs.
    -- It will generate report statements depending on the chosen verbosity level.
    -- It also allow to write the logs in a selected file.
    -- 
    -- It is suggested to use a single shared variable of that type, declared
    -- in a project package, so that every component can access it.
    --
    type logger_t is protected

        -- procedure to log error in console
        procedure log_error;

        -- procedure to compute number of error
        procedure final_report;

        procedure set_verbosity(level : severity_level);

        -- Labo
        impure function init_output_file (filename : string) return boolean;
        procedure note    (msg : string);
        procedure warning (msg : string);
        procedure error   (msg : string);
        procedure failure (msg : string);

    end protected logger_t;

end logger_pkg;


`protect begin_protected
`protect version = 1
`protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "2020.1_1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
RUEhnnzE993E0tVxRd5cwxY1UB1DDhGQu0sGBxeU7IDLD2NXP9H/iH5ZjaoL0KDA
u93leGDnbXtZc19/rC7GccqhZcCsQ1uggWjPdzwuQQeO2Mz0EWb+yeorR88dMfKw
+dH6atVL9NKW1wL7nI2qnbw28BSn9kdxWKTQ8Jm8OQlvKNfMPloM7RYL/Re4zAZ8
2VaXceB6iylxuI6yEUG9bD9ZT9uAG9vfFxNSecjFRx50oONSdvPDQ2EBo8X1TApu
XBl0hmu/KjjcafvSgjW9B4TovP8xiiswz0kpoYCdt7QJDmOBu9r4bXl34jHRMFjF
BMO0rgi9jXkV0xLuoQdy0A==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 3376 )
`protect data_block
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
flWgFmnYjiolzLkqhJUzXg==
`protect end_protected

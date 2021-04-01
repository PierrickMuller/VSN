--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : project_ctx.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : A context for the entire project, simplifying the use clauses.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 0.1   31.03.2021  YTA        Initial version
--------------------------------------------------------------------------------

context project_ctx is -- To be compiled in project_lib

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


    use std.env.all;
    
    library common_lib;
    use project_lib.project_logger_pkg.all;

    library morse;
    use morse.morse_pkg.all;
    use morse.morse_burst_emitter_pkg.all;

end context project_ctx;

--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : project_logger_pkg.vhd
-- Author   : Yann Thoma
-- Date     : 31.03.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : This package offers a single logger as a shared variable.
--               It can be used from anywhere in the testbench, and ensures
--               all logs are centralized.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 0.1   31.03.2021  YTA        Initial version
--------------------------------------------------------------------------------

library common_lib;
context common_lib.common_ctx;

package project_logger_pkg is

    -- Simply exports a logger that can be used accross entities
    shared variable logger : common_lib.logger_pkg.logger_t;

end project_logger_pkg;

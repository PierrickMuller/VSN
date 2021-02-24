-------------------------------------------------------------------------------
--    Copyright 2018 HES-SO HEIG-VD REDS
--    All Rights Reserved Worldwide
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.
-------------------------------------------------------------------------------
--
-- File        : html_report_tb.vhd
-- Description : This testbench demonstrates a way to exploit the
--               html_report_pkg pacakge.
--               sim.do and sim_nodate.do scripts compile and start the
--               simulation. The first one uses a force command to set the
--               the current date.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 07.03.18
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  07.03.18  YTA   First version
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.html_report_pkg.all;

entity html_report_tb is
end html_report_tb;

architecture testbench of html_report_tb is

    file report_file: text open write_mode is "generated_report.html";

    signal date_time_str : string (1 to 28);

begin

    process is
        variable l: line;
    begin

        -- default value for date.
        -- It will be erased in case of sim.do script is used
        date_time_str(1 to 9) <= " UNKNOWN ";
        date_time_str(10 to date_time_str'high) <= (others => ' ');
        wait for 0 ns;

        write(l,string'("That's a simulation!"));
        html_start(report_file,l,date_time_str);

        for i in 0 to 1 loop
            html_report(report_file,string'("Here is a warning"),WARNING);
            wait for 10 ns;

            html_report(report_file,string'("Here is a note"),NOTE);
            wait for 10 ns;

            write(l,string'("Here is an error"));
            html_write(report_file,l,ERROR);
            wait for 10 ns;

            write(l,string'("Here is a failure"));
            html_write(report_file,l,FAILURE);
            wait for 10 ns;
        end loop;

        html_end(report_file);
        wait;
    end process;

end testbench;

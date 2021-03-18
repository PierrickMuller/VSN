--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : com_store_velux_tb.vhd
-- Author   : TbGenerator
-- Date     : 18.02.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : This module is a simple VHDL testbench.
--               It instanciates the DUV and proposes a TESTCASE generic to
--               select which test to start.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 0.1   18.02.2021  TbGen      Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity com_store_velux_tb is
    generic (
        TESTCASE : integer := 0;
        N        : integer := 3;
        ERRNO    : integer := 0
    );
    
end com_store_velux_tb;

architecture testbench of com_store_velux_tb is

    signal temp_sti  : std_logic_vector(N - 1 downto 0);
    signal sun_sti   : std_logic_vector(N - 1 downto 0);
    signal rain_sti  : std_logic;
    signal wind_sti  : std_logic;
    signal velux_obs : std_logic_vector(2 downto 0);
    signal store_obs : std_logic_vector(7 downto 0);
    
    signal sim_end_s : boolean := false;

    component com_store_velux is
    generic (
        N     : integer := 3;
        ERRNO : integer := 0
    );
    port (
        temp_i  : in std_logic_vector(N - 1 downto 0);
        sun_i   : in std_logic_vector(N - 1 downto 0);
        rain_i  : in std_logic;
        wind_i  : in std_logic;
        velux_o : out std_logic_vector(2 downto 0);
        store_o : out std_logic_vector(7 downto 0)
    );
    end component;
    

begin

    duv : com_store_velux
    generic map (
        N     => N,
        ERRNO => ERRNO
    )
    port map (
        temp_i  => temp_sti,
        sun_i   => sun_sti,
        rain_i  => rain_sti,
        wind_i  => wind_sti,
        velux_o => velux_obs,
        store_o => store_obs
    );
    

    stimulus_proc: process is
    begin
        -- temp_sti  <= default_value;
        -- sun_sti   <= default_value;
        -- rain_sti  <= default_value;
        -- wind_sti  <= default_value;
        

        -- do something
        case TESTCASE is
            when 0      => -- default testcase
            when others => report "Unsupported testcase : "
                                  & integer'image(TESTCASE)
                                  severity error;
        end case;

        -- end of simulation
        sim_end_s <= true;

        -- stop the process
        wait;

    end process; -- stimulus_proc

end testbench;

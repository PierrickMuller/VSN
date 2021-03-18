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

    type stimulus_t is record
        temp_i : std_logic_vector(N - 1 downto 0);
        sun_i  : std_logic_vector(N - 1 downto 0);
        rain_i : std_logic;
        wind_i : std_logic;
    end record;
    
    type observed_t is record
        velux_o : std_logic_vector(2 downto 0);
        store_o : std_logic_vector(7 downto 0);
    end record;
    

    signal stimulus_sti  : stimulus_t;
    signal observed_obs  : observed_t;
    signal reference_ref : observed_t;

    constant PERIOD : time := 10 ns;

    signal sim_end_s : boolean   := false;
    signal synchro_s : std_logic := '0';

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
    

    procedure check(stimulus  : stimulus_t;
                    observed  : observed_t;
                    reference : observed_t) is
    begin
        -- TODO : do the check, maybe differently
        if (observed /= reference) then
            report "Error in check" severity error;
        end if;
    end check;

    procedure calculate_reference(stimulus : stimulus_t;
                                  reference : out observed_t) is
    begin
        -- TODO : calculate the reference

    end calculate_reference;


    procedure testcase0(signal synchro : in std_logic;
                        signal stimulus : out stimulus_t;
                        signal reference : out observed_t) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : observed_t;

    begin
        for i in 0 to 9 loop
            wait until rising_edge(synchro);
            -- TODO : assign the stimulus_v variable
             stimulus_v.temp_i := std_logic_vector(to_unsigned(i, N));
             stimulus_v.sun_i  := std_logic_vector(to_unsigned(i, N));
             stimulus_v.rain_i := '0';
             stimulus_v.wind_i := '0';
            

            stimulus <= stimulus_v;
            calculate_reference(stimulus_v, reference_v);
            reference <= reference_v;
        end loop;
    end testcase0;

begin

    duv : com_store_velux
    generic map (
        N     => N,
        ERRNO => ERRNO
    )
    port map (
        temp_i  => stimulus_sti.temp_i,
        sun_i   => stimulus_sti.sun_i,
        rain_i  => stimulus_sti.rain_i,
        wind_i  => stimulus_sti.wind_i,
        velux_o => observed_obs.velux_o,
        store_o => observed_obs.store_o
    );
    

    synchro_proc : process is
    begin
        while not(sim_end_s) loop
            synchro_s <= '0', '1' after PERIOD/2;
            wait for PERIOD;
        end loop;
        wait;
    end process;

    verif_proc : process is
    begin
        loop
            wait until falling_edge(synchro_s);
            check(stimulus_sti, observed_obs, reference_ref);
        end loop;
    end process;

    stimulus_proc: process is
    begin
         stimulus_sti.temp_i <= (others => '0');
         stimulus_sti.sun_i  <= (others => '0');
         stimulus_sti.rain_i <= '0';
         stimulus_sti.wind_i <= '0';
        

        report "Running TESTCASE " & integer'image(TESTCASE) severity note;

        -- do something
        case TESTCASE is
            when 0      => -- default testcase

                testcase0(synchro_s, stimulus_sti, reference_ref);

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

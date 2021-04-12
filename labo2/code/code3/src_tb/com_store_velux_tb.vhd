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
-- Author   : Pierrick Muller
-- Date     : 18.02.2021
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : Testbench for Labo2 VSN, it test a system that simulate 
--               the functionnement of store and velux.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person             Comments
-- 0.1   18.02.2021  TbGen              Initial version
-- 0.2   18.02.2021  Pierrick Muller    Modification for the purpose of Labo 2 VSN
--------------------------------------------------------------------------------

library project_lib;
context project_lib.project_ctx;

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
    signal dontCare_s    : std_logic;
    
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
    
    -- This procedure is used to compare observed results from the duv and reference results from the TB.
    -- It generate an error if results are not correct regarding the functionnement of the system
    -- Errors and success are logged.
    procedure check(stimulus  : stimulus_t;
                    observed  : observed_t;
                    reference : observed_t;
                    dontCare  : std_logic) is
    begin

        -- Check the validity of the observed results
        if  observed.velux_o /= reference.velux_o or (observed.store_o /= reference.store_o and dontCare /= '1') then
            
            -- Log error with stimulus, observed and reference
            logger.log_error("Error in check" & LF & "Stimulus :" & LF & 
            "temp_i  (hex) : " & to_hstring(stimulus.temp_i) & LF &
            "sun_i   (hex) : "  & to_hstring(stimulus.sun_i ) & LF & 
            "rain_i        : " & std_logic'image(stimulus.rain_i) & LF & 
            "wind_i        : " & std_logic'image(stimulus.wind_i) & LF & LF & 
            "Observed : " & LF & 
            "velux_o (hex) : " & to_hstring(observed.velux_o) & LF & 
            "store_o (hex) : " & to_hstring(observed.store_o) & LF & LF & 
            "Reference : " & LF & 
            "velux_o (hex) : " & to_hstring(reference.velux_o) & LF & 
            "store_o (hex) : " & to_hstring(reference.store_o) & LF );
        
        else 
            -- Log note with stimulus only if result is correct
            logger.log_note("OK" & LF & "Stimulus :" & LF & 
            "temp_i (hex) : " & to_hstring(stimulus.temp_i) & LF &
            "sun_i  (hex) : "  & to_hstring(stimulus.sun_i ) & LF & 
            "rain_i       : " & std_logic'image(stimulus.rain_i) & LF & 
            "wind_i       : " & std_logic'image(stimulus.wind_i) & LF );

        end if;
    end check;

    -- This procedure calculate the reference based on the simulus it get
    -- First it scale the temperature and sun to a number beetween 0 and 7
    -- Then it set the reference value (velux and store) to the right value 
    -- Results values are defined in the document of the Labo2 VSN 
    procedure calculate_reference(stimulus : inout stimulus_t;
                                  reference : out observed_t;
                                  dontCare : out std_logic) is
        variable store_res_v : std_logic_vector(7 downto 0) := (others=>'0');
        variable velux_res_v : std_logic_vector(2 downto 0) := (others=>'0');
        variable temp_int_v : integer := 0;
        variable sun_int_v : integer := 0;
        variable shift_value_v : integer := 0;
        variable i : integer := 0;
    begin

        dontCare := '0';
        -- Scale temperature and sun
        temp_int_v := integer(floor(real(to_integer(unsigned(stimulus.temp_i))) / real(2 ** ( N - 3))));
        sun_int_v := integer(floor(real(to_integer(unsigned(stimulus.sun_i))) / real(2 ** ( N - 3))));

        -- Translation of the velux graph and management of not defined behavior
        if stimulus.rain_i = '0' then
            case temp_int_v is
                when 0 to 2 => 
                    null;
                when 3 to 5 =>
                    velux_res_v := std_logic_vector(to_unsigned((temp_int_v - 2),velux_res_v'length));
                when 6 to 7 => 
                    velux_res_v := std_logic_vector(to_unsigned((temp_int_v - (7 - temp_int_v)),velux_res_v'length));
                when others => 
                    null;
            end case;     
        else 
            if sun_int_v = 6 or sun_int_v = 7 then
                dontCare := '1';   
            end if;
        end if;
        
        
        -- Translation of the store graph
        if stimulus.wind_i = '0' then 
            case temp_int_v is 
                when 0 to 2 =>
                    null;
                when 3 to 5 =>
                    shift_value_v := integer(floor(real(sun_int_v)/real(2))) + 1;
                when 6 to 7 => 
                    shift_value_v := sun_int_v + 1;
                when others => 
                    null;
            end case;
            -- Store representation
            while i < shift_value_v loop
                store_res_v := store_res_v(6 downto 0) & '1';
                i := i+1;
            end loop;
        end if;
        
        -- signals assignement 
        reference.velux_o := velux_res_v; 
        reference.store_o := store_res_v;

    end calculate_reference;
    
    -- This procedure is an util used by testcase1 and testcase2.
    -- It let found the minimal value that convert to a number beetween
    -- 0 and 7 based on the formula of the labo2 VSN
    procedure count_step(nb_step : in integer;
                        value_step : in unsigned(N-1 downto 0);
                        value_result : inout unsigned(N-1 downto 0)) is
                            
        variable step_cnt_v : integer := 0;
    begin
        while step_cnt_v < nb_step loop
            value_result := value_result + value_step;
            step_cnt_v := step_cnt_v + 1;
        end loop;
    end count_step; 

    -- This procedure is an util used by testcase 2
    -- It help find the maximal value that convert to a number beetween 
    -- 0 and 7 based on the formula of the labo2 VSN, you have to give 
    -- this procedure the corresponding minimal value. Use "count_step"
    -- for that.
    procedure calculate_max(value_step : in unsigned(N-1 downto 0);
                            value_result : inout unsigned(N-1 downto 0)) is 
    begin 
        value_result := value_result + value_step;
        value_result := value_result - 1;
    end calculate_max;
    

    -- Testcase 0 : This testcase generate the stimulis and calculate the 
    -- reference for all the combination of input of the system, based on N
    -- You shouldn't use this testcase with N too big, depending of your machine,
    procedure testcase0(signal synchro : in std_logic;
                        signal stimulus : out stimulus_t;
                        signal reference : out observed_t;
                        signal dontcare : out std_logic) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : observed_t;
        variable dontCare_v  : std_logic;
    begin

        -- iterate over each scenarios
        for i in 0 to (2 ** N) - 1 loop
            for y in 0 to (2 ** N) - 1 loop
                for z in std_logic range '0' to '1' loop
                    for v in std_logic range '0' to '1' loop
                        wait until rising_edge(synchro);
                        
                        -- Set values for temp and sun
                        stimulus_v.temp_i := std_logic_vector(to_unsigned(i, N));
                        stimulus_v.sun_i  := std_logic_vector(to_unsigned(y, N));
                        
                         -- set values for rain an wind, set not defined behavior
                        stimulus_v.rain_i := z;
                        stimulus_v.wind_i := v;
                        dontCare_v := '0';

                        -- calculate reference
                        stimulus <= stimulus_v;
                        calculate_reference(stimulus_v, reference_v, dontCare_v);
                        reference <= reference_v;
                        dontcare <= dontcare_v;
                    end loop;
                end loop;
            end loop;
        end loop;
        wait until rising_edge(synchro);
    end testcase0;

    -- Testcase 1 : This testcase generate the stimulus and calculate the 
    -- reference for a combination of random temp_i and sun_i input, in order
    -- to represent all the possible converted input scenarios. This testcase
    -- always test the same amount of scénarios (256, one test for each combination
    -- of system with N=3)
    procedure testcase1(signal synchro : in std_logic;
                        signal stimulus : out stimulus_t;
                        signal reference : out observed_t;
                        signal dontcare : out std_logic) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : observed_t;
        variable dontCare_v  : std_logic;
        variable seed1_v, seed2_v : positive;
        variable rand_v: real;
        variable int_rand_v: integer;
        variable value_v : unsigned(N-1 downto 0) := (others => '0');
        variable value_step_v : unsigned(N-1 downto 0) := (others => '0');
    begin

        -- Calulate step value for each slice
        value_step_v := to_unsigned(1, N);
        value_step_v := shift_left(value_step_v,(N-3));

        -- iterate over each scenarios
        for i in 0 to (2 ** 3) - 1 loop
            for y in 0 to (2 ** 3) - 1 loop
                for z in std_logic range '0' to '1' loop
                    for v in std_logic range '0' to '1' loop
                        wait until rising_edge(synchro);
                        
                        -- Random number beetween 0 and 2^(N-3) - 1 
                        UNIFORM(seed1_v,seed2_v,rand_v);
                        int_rand_v := INTEGER(TRUNC(rand_v*real(2**(N-3)-1))); 

                        -- Calculate min value for slice temp and add random number
                        count_step(i,value_step_v,value_v);
                        value_v := value_v + to_unsigned(int_rand_v,N);
                        stimulus_v.temp_i := std_logic_vector(value_v);
                        value_v := (others => '0');

                        -- Calculate min value for slice sun and add random number
                        count_step(y,value_step_v,value_v);
                        value_v := value_v + to_unsigned(int_rand_v,N);
                        stimulus_v.sun_i := std_logic_vector(value_v);
                        value_v := (others => '0');

                        -- set values for rain an wind, set not defined behavior
                        stimulus_v.rain_i := z;
                        stimulus_v.wind_i := v;
                        dontCare_v := '0';

                        -- calculate reference
                        stimulus <= stimulus_v;
                        calculate_reference(stimulus_v, reference_v, dontCare_v);
                        reference <= reference_v;
                        dontcare <= dontcare_v;
                    end loop;
                end loop;
            end loop;
        end loop;
        wait until rising_edge(synchro);
    end testcase1;

    -- Testcase 2 : This testcase generate the stimulus and calculate the 
    -- reference for a combination of all the "limits" case that the system can encounter
    -- "Limits" are the min and max of a slice from the range 0 to 7. More informations
    -- about this testcase can be found on the report created for this labo. This testcase
    -- alwayse test the same amount of scénarios (1024, 4 test for each combination of system
    -- with N=3 because for each scénario with test all the combination of min/max)
    procedure testcase2(signal synchro : in std_logic;
                        signal stimulus : out stimulus_t;
                        signal reference : out observed_t;
                        signal dontcare : out std_logic) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : observed_t;
        variable dontCare_v  : std_logic;
        variable value_v : unsigned(N-1 downto 0) := (others => '0');
        variable value_step_v : unsigned(N-1 downto 0) := (others => '0');
    begin
        -- Calulate step value for each slice
        value_step_v := to_unsigned(1, N);
        value_step_v := shift_left(value_step_v,(N-3));

        -- iterate over each scenarios
        for i in 0 to (2 ** 3) - 1 loop
            for y in 0 to (2 ** 3) - 1 loop
                for z in std_logic range '0' to '1' loop
                    for v in std_logic range '0' to '1' loop
                        for ii in 0 to 1 loop
                            for yy in 0 to 1 loop
                                wait until rising_edge(synchro); 


                                -- Calculate min value for slice temp
                                count_step(i,value_step_v,value_v);

                                -- Calculate max value for slice temp if needed
                                if ii = 1 then
                                    calculate_max(value_step_v,value_v);
                                end if;
                                stimulus_v.temp_i := std_logic_vector(value_v);
                                value_v := (others => '0');
                                
                                -- Calculate min value for slice sun
                                count_step(y,value_step_v,value_v);

                                -- Calculate max value for slice sun if needed
                                if yy = 1 then 
                                    calculate_max(value_step_v,value_v);
                                end if;
                                stimulus_v.sun_i := std_logic_vector(value_v);
                                value_v := (others => '0');

                                -- set values for rain an wind, set not defined behavior
                                stimulus_v.rain_i := z;
                                stimulus_v.wind_i := v;
                                dontCare_v := '0';

                                -- calculate reference
                                stimulus <= stimulus_v;
                                calculate_reference(stimulus_v, reference_v, dontCare_v);
                                reference <= reference_v;
                                dontcare <= dontcare_v;
                            end loop;
                        end loop;
                    end loop;
                end loop;
            end loop;
        end loop;
        wait until rising_edge(synchro);
    end testcase2;

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
            check(stimulus_sti, observed_obs, reference_ref,dontCare_s);
        end loop;
    end process;

    stimulus_proc: process is
        variable file_status : FILE_OPEN_STATUS;
    begin
        -- Stimulus and utils initialization
         stimulus_sti.temp_i <= (others => '0');
         stimulus_sti.sun_i  <= (others => '0');
         stimulus_sti.rain_i <= '0';
         stimulus_sti.wind_i <= '0';
         dontCare_s <= '0';

        -- Logger initialization
        logger.define_verbosity(ERROR);
        file_status := logger.init("log.txt");
        logger.log_note("Running TESTCASE " & integer'image(TESTCASE));
        --report "Running TESTCASE " & integer'image(TESTCASE) severity note;

        case TESTCASE is
            when 0      => -- default testcase
                testcase0(synchro_s, stimulus_sti, reference_ref,dontCare_s);
                testcase1(synchro_s, stimulus_sti, reference_ref,dontCare_s);
                testcase2(synchro_s, stimulus_sti, reference_ref,dontCare_s);
            when 1      => -- Testcase complet
                testcase0(synchro_s, stimulus_sti, reference_ref,dontCare_s);
            when 2      => -- Testcase "Aléatoire"
                testcase1(synchro_s, stimulus_sti, reference_ref,dontCare_s);
            when 3      => -- Testcase limite
                testcase2(synchro_s, stimulus_sti, reference_ref,dontCare_s);
            when others => report "Unsupported testcase : "
                                  & integer'image(TESTCASE)
                                  severity error;
        end case;

        -- Get total errors and warning 
        logger.final_report;

        -- end of simulation
        sim_end_s <= true;

        -- stop the process
        wait;

    end process; -- stimulus_proc

end testbench;

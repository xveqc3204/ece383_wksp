----------------------------------------------------------------------------------
-- Module Name: top - Behavioral
-- Description: Top-level wrapper for the NES-controlled robot arm.
--
-- This file contains TWO build configurations.  Only one is active at a time;
-- the other is left commented out as a debugging fallback.
--
--   ACTIVE (below):  Full multi-joint button-mapping demo.  Uses the FSM,
--                    register file, clamp, and PWM generator to drive all six
--                    joints from the NES controller.
--
--   COMMENTED OUT:   Shoulder-only smooth-motion demo.  No FSM, no joint
--                    selection.  Updates shoulder_cmd exactly once per PWM
--                    period (20 ms) so each pulse is internally consistent.
--                    This is the simplest path that produced smooth motion
--                    on a single servo and is kept here as a reference for
--                    future debugging of motion quality.
----------------------------------------------------------------------------------


-- ===================================================================
-- ALTERNATE: shoulder-only smooth-motion demo (commented out)
-- Uncomment this block and comment out the active block below to use.
-- ===================================================================

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity top is
--    port ( clk          : in  STD_LOGIC;
--           reset_n      : in  STD_LOGIC;
--           nes_data     : in  STD_LOGIC;
--           nes_latch    : out STD_LOGIC;
--           nes_pulse    : out STD_LOGIC;
--           pwm_out      : out STD_LOGIC_VECTOR(5 downto 0);
--           led_selected : out STD_LOGIC_VECTOR(2 downto 0));
--end top;

--architecture Behavioral of top is

--    -- =========================================================================
--    -- Servo PWM constants
--    -- =========================================================================
--    constant PERIOD_CYCLES : integer := 2000000;   -- 20 ms at 100 MHz
--    constant CMD_HOME : integer := 150000;          -- 1.5 ms
--    constant CMD_MIN  : integer := 130000;          -- 1.3 ms
--    constant CMD_MAX  : integer := 170000;          -- 1.7 ms
--    constant STEP_SIZE : integer := 30;             -- counts per PWM period

--    -- =========================================================================
--    -- NES bit positions (standard layout)
--    -- =========================================================================
--    constant BIT_RIGHT  : integer := 0;
--    constant BIT_LEFT   : integer := 1;
--    constant BIT_START  : integer := 4;

--    -- =========================================================================
--    -- nes_interface component declaration (uses your existing module)
--    -- =========================================================================
--    component nes_interface
--        generic ( half_period_cycles : integer := 1200;
--                  frame_gap_cycles : integer := 1600000 );
--        port ( clk          : in  STD_LOGIC;
--               reset_n      : in  STD_LOGIC;
--               nes_data     : in  STD_LOGIC;
--               nes_latch    : out STD_LOGIC;
--               nes_pulse    : out STD_LOGIC;
--               button_state : out STD_LOGIC_VECTOR(7 downto 0));
--    end component;

--    -- =========================================================================
--    -- Signals
--    -- =========================================================================
--    signal counter   : unsigned(20 downto 0) := (others => '0');
--    signal shoulder_cmd : unsigned(20 downto 0) := to_unsigned(CMD_HOME, 21);
--    signal buttons   : STD_LOGIC_VECTOR(7 downto 0);

--    -- Update flag: pulses high for one cycle at the end of each PWM period
--    signal period_done : STD_LOGIC := '0';

--    -- 3-stage synchronizer for buttons (extra noise filtering)
--    signal btn_sync_1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
--    signal btn_sync_2 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
--    signal btn_stable : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

--    -- Heartbeat
--    signal heartbeat : unsigned(26 downto 0) := (others => '0');

--begin

--    -- =========================================================================
--    -- NES interface (your existing working module)
--    -- =========================================================================
--    nes_inst : nes_interface
--        port map ( clk          => clk,
--                   reset_n      => reset_n,
--                   nes_data     => nes_data,
--                   nes_latch    => nes_latch,
--                   nes_pulse    => nes_pulse,
--                   button_state => buttons );

--    -- =========================================================================
--    -- Triple synchronize button state (deep noise filtering)
--    -- =========================================================================
--    btn_sync : process(clk)
--    begin
--        if rising_edge(clk) then
--            btn_sync_1 <= buttons;
--            btn_sync_2 <= btn_sync_1;
--            btn_stable <= btn_sync_2;
--        end if;
--    end process;

--    -- =========================================================================
--    -- 20 ms PWM counter (shared by all 6 channels)
--    -- period_done pulses high at the end of each cycle - this is when we
--    -- update the cmd value so that each pulse is consistent.
--    -- =========================================================================
--    counter_proc : process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                counter <= (others => '0');
--                period_done <= '0';
--            elsif counter = to_unsigned(PERIOD_CYCLES - 1, counter'length) then
--                counter <= (others => '0');
--                period_done <= '1';   -- pulse high for 1 cycle when period ends
--            else
--                counter <= counter + 1;
--                period_done <= '0';
--            end if;
--        end if;
--    end process;

--    -- =========================================================================
--    -- Update shoulder_cmd ONCE per PWM period (20 ms).
--    -- This is the key to smooth motion: cmd changes between pulses, never
--    -- during a pulse.  The servo gets one consistent pulse, then the next
--    -- pulse is slightly different.
--    -- =========================================================================
--    cmd_update : process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                shoulder_cmd <= to_unsigned(CMD_HOME, 21);
--            elsif period_done = '1' then
--                -- Start button: snap to home (highest priority)
--                if btn_stable(BIT_START) = '1' then
--                    shoulder_cmd <= to_unsigned(CMD_HOME, 21);
--                -- Right button: increase cmd (move forward)
--                elsif btn_stable(BIT_RIGHT) = '1' then
--                    if shoulder_cmd < to_unsigned(CMD_MAX, 21) then
--                        shoulder_cmd <= shoulder_cmd + STEP_SIZE;
--                    end if;
--                -- Left button: decrease cmd (move backward)
--                elsif btn_stable(BIT_LEFT) = '1' then
--                    if shoulder_cmd > to_unsigned(CMD_MIN, 21) then
--                        shoulder_cmd <= shoulder_cmd - STEP_SIZE;
--                    end if;
--                end if;
--                -- If no buttons pressed, cmd holds current value
--            end if;
--        end if;
--    end process;

--    -- =========================================================================
--    -- Heartbeat
--    -- =========================================================================
--    heartbeat_proc : process(clk)
--    begin
--        if rising_edge(clk) then
--            heartbeat <= heartbeat + 1;
--        end if;
--    end process;

--    -- =========================================================================
--    -- PWM outputs
--    -- =========================================================================
--    -- Joint 0 (JB1) is the shoulder, driven by shoulder_cmd
--    pwm_out(0) <= '1' when counter < shoulder_cmd else '0';
--    -- All other joints hold at home (1.5 ms) so they stay still
--    pwm_out(1) <= '1' when counter < to_unsigned(CMD_HOME, counter'length) else '0';
--    pwm_out(2) <= '1' when counter < to_unsigned(CMD_HOME, counter'length) else '0';
--    pwm_out(3) <= '1' when counter < to_unsigned(CMD_HOME, counter'length) else '0';
--    pwm_out(4) <= '1' when counter < to_unsigned(CMD_HOME, counter'length) else '0';
--    pwm_out(5) <= '1' when counter < to_unsigned(CMD_HOME, counter'length) else '0';

--    -- LED diagnostics
--    led_selected(0) <= btn_stable(BIT_RIGHT);  -- lights when Right held
--    led_selected(1) <= btn_stable(BIT_LEFT);   -- lights when Left held
--    led_selected(2) <= heartbeat(26);          -- heartbeat blink

--end Behavioral;


-- ===================================================================
-- ACTIVE: full multi-joint button-mapping demo
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top is
    generic (
        nes_half_period_cycles : integer := 1200;
        nes_frame_gap_cycles   : integer := 1600000;
        pwm_period_cycles      : integer := 2000000;
        pwm_num_bits           : integer := 18;
        -- Home values (consistent across joint_regfile + control_fsm)
        home_0 : integer := 150000;
        home_1 : integer := 150000;
        home_2 : integer := 150000;
        home_3 : integer := 150000;
        home_4 : integer := 150000;
        home_5 : integer := 150000
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           nes_data : in STD_LOGIC;
           nes_latch : out STD_LOGIC;
           nes_pulse : out STD_LOGIC;
           pwm_out : out std_logic_vector(5 downto 0);
           led_selected : out std_logic_vector(2 downto 0));
end top;

architecture Behavioral of top is

component nes_interface
    generic ( half_period_cycles : integer := 1200;
              frame_gap_cycles : integer := 1600000 );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           nes_data : in STD_LOGIC;
           nes_latch : out STD_LOGIC;
           nes_pulse : out STD_LOGIC;
           button_state : out std_logic_vector(7 downto 0));
end component;

component button_reg
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           d : in std_logic_vector(7 downto 0);
           q : out std_logic_vector(7 downto 0));
end component;

component control_fsm
    generic (
        home_0 : integer := 150000;
        home_1 : integer := 150000;
        home_2 : integer := 150000;
        home_3 : integer := 150000;
        home_4 : integer := 150000;
        home_5 : integer := 150000
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           buttons : in std_logic_vector(7 downto 0);
           cmd_0 : in unsigned(17 downto 0);
           cmd_1 : in unsigned(17 downto 0);
           cmd_2 : in unsigned(17 downto 0);
           cmd_3 : in unsigned(17 downto 0);
           cmd_4 : in unsigned(17 downto 0);
           cmd_5 : in unsigned(17 downto 0);
           sel : out unsigned(2 downto 0);
           wr_en : out STD_LOGIC;
           wr_data : out unsigned(17 downto 0);
           selected_led : out unsigned(2 downto 0));
end component;

component joint_regfile
    generic (
        home_0 : integer := 150000;
        home_1 : integer := 150000;
        home_2 : integer := 150000;
        home_3 : integer := 150000;
        home_4 : integer := 150000;
        home_5 : integer := 150000
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sel : in unsigned(2 downto 0);
           wr_en : in STD_LOGIC;
           wr_data : in unsigned(17 downto 0);
           cmd_0 : out unsigned(17 downto 0);
           cmd_1 : out unsigned(17 downto 0);
           cmd_2 : out unsigned(17 downto 0);
           cmd_3 : out unsigned(17 downto 0);
           cmd_4 : out unsigned(17 downto 0);
           cmd_5 : out unsigned(17 downto 0));
end component;

component limit_clamp
    port ( raw_0 : in unsigned(17 downto 0);
           raw_1 : in unsigned(17 downto 0);
           raw_2 : in unsigned(17 downto 0);
           raw_3 : in unsigned(17 downto 0);
           raw_4 : in unsigned(17 downto 0);
           raw_5 : in unsigned(17 downto 0);
           cmd_0 : out unsigned(17 downto 0);
           cmd_1 : out unsigned(17 downto 0);
           cmd_2 : out unsigned(17 downto 0);
           cmd_3 : out unsigned(17 downto 0);
           cmd_4 : out unsigned(17 downto 0);
           cmd_5 : out unsigned(17 downto 0));
end component;

component pwm_gen
    generic ( period_cycles : integer := 2000000;
              num_bits : integer := 18 );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           cmd_0 : in unsigned(17 downto 0);
           cmd_1 : in unsigned(17 downto 0);
           cmd_2 : in unsigned(17 downto 0);
           cmd_3 : in unsigned(17 downto 0);
           cmd_4 : in unsigned(17 downto 0);
           cmd_5 : in unsigned(17 downto 0);
           pwm_out : out std_logic_vector(5 downto 0));
end component;

-- internal wires
signal nes_buttons : std_logic_vector(7 downto 0);
signal stable_buttons : std_logic_vector(7 downto 0);
signal sel : unsigned(2 downto 0);
signal wr_en : std_logic;
signal wr_data : unsigned(17 downto 0);
signal raw_0, raw_1, raw_2, raw_3, raw_4, raw_5 : unsigned(17 downto 0);
signal cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5 : unsigned(17 downto 0);
signal selected : unsigned(2 downto 0);

begin

    nes : nes_interface
        generic map (
            half_period_cycles => nes_half_period_cycles,
            frame_gap_cycles   => nes_frame_gap_cycles
        )
        port map(
            clk => clk,
            reset_n => reset_n,
            nes_data => nes_data,
            nes_latch => nes_latch,
            nes_pulse => nes_pulse,
            button_state => nes_buttons);

    btn_reg : button_reg port map(
        clk => clk,
        reset_n => reset_n,
        d => nes_buttons,
        q => stable_buttons);

    -- FSM reads CLAMPED values (cmd_*) so feedback loop is bounded.
    fsm : control_fsm
        generic map (
            home_0 => home_0,
            home_1 => home_1,
            home_2 => home_2,
            home_3 => home_3,
            home_4 => home_4,
            home_5 => home_5
        )
        port map(
            clk => clk,
            reset_n => reset_n,
            buttons => stable_buttons,
            cmd_0 => cmd_0, cmd_1 => cmd_1, cmd_2 => cmd_2,
            cmd_3 => cmd_3, cmd_4 => cmd_4, cmd_5 => cmd_5,
            sel => sel,
            wr_en => wr_en,
            wr_data => wr_data,
            selected_led => selected);

    -- Regfile initializes to home values on reset.
    regfile : joint_regfile
        generic map (
            home_0 => home_0,
            home_1 => home_1,
            home_2 => home_2,
            home_3 => home_3,
            home_4 => home_4,
            home_5 => home_5
        )
        port map(
            clk => clk,
            reset_n => reset_n,
            sel => sel,
            wr_en => wr_en,
            wr_data => wr_data,
            cmd_0 => raw_0, cmd_1 => raw_1, cmd_2 => raw_2,
            cmd_3 => raw_3, cmd_4 => raw_4, cmd_5 => raw_5);

    clamp : limit_clamp port map(
        raw_0 => raw_0, raw_1 => raw_1, raw_2 => raw_2,
        raw_3 => raw_3, raw_4 => raw_4, raw_5 => raw_5,
        cmd_0 => cmd_0, cmd_1 => cmd_1, cmd_2 => cmd_2,
        cmd_3 => cmd_3, cmd_4 => cmd_4, cmd_5 => cmd_5);

    pwm : pwm_gen
        generic map (
            period_cycles => pwm_period_cycles,
            num_bits      => pwm_num_bits
        )
        port map(
            clk => clk,
            reset_n => reset_n,
            cmd_0 => cmd_0, cmd_1 => cmd_1, cmd_2 => cmd_2,
            cmd_3 => cmd_3, cmd_4 => cmd_4, cmd_5 => cmd_5,
            pwm_out => pwm_out);

    led_selected <= std_logic_vector(selected);

end Behavioral;
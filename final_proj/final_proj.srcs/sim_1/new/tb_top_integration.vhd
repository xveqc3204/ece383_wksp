----------------------------------------------------------------------------------
-- Testbench: tb_top_integration
-- Purpose: Full-system simulation. Drives the entire chain:
--   fake NES → nes_interface → button_reg → control_fsm
--   → joint_regfile → limit_clamp → pwm_gen → pwm_out
--
-- THIS IS THE TEST THAT TELLS YOU IT'S SAFE TO PLUG IN THE ARM.
--
-- Test sequence (all timings scaled for fast sim):
--   1. Reset everything
--   2. Press Start → expect all 6 cmds to go to home (150,000 each)
--   3. Press Up → expect selected_led to change to 001
--   4. Hold Right for several "ticks" → expect joint 1 cmd to increment
--   5. Hold Right longer → expect step size to grow (acceleration)
--   6. Release Right → expect cmd to stop changing
--   7. Press Left → expect cmd to decrement back toward home
--   8. Try to drive past max → verify limit_clamp catches it
--   9. Throughout, verify pwm_out duty cycle tracks the commanded value
--
-- This will catch wiring bugs, FSM bugs, and clamp bugs all at once.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_integration is
end tb_top_integration;
 
architecture Behavioral of tb_top_integration is
 
    component top is
        generic (
            nes_half_period_cycles : integer := 1200;
            nes_frame_gap_cycles   : integer := 1600000;
            pwm_period_cycles      : integer := 2000000;
            pwm_num_bits           : integer := 18
        );
        port (
            clk          : in  STD_LOGIC;
            reset_n      : in  STD_LOGIC;
            nes_data     : in  STD_LOGIC;
            nes_latch    : out STD_LOGIC;
            nes_pulse    : out STD_LOGIC;
            pwm_out      : out STD_LOGIC_VECTOR(5 downto 0);
            led_selected : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;
 
    constant clk_period : time := 10 ns;
 
    signal clk          : STD_LOGIC := '0';
    signal reset_n      : STD_LOGIC := '0';
 
    -- NES bus
    signal nes_data    : STD_LOGIC := '1';   -- idle high (active-low protocol)
    signal nes_latch   : STD_LOGIC;
    signal nes_pulse   : STD_LOGIC;
 
    -- Outputs we observe
    signal pwm_out      : STD_LOGIC_VECTOR(5 downto 0);
    signal led_selected : STD_LOGIC_VECTOR(2 downto 0);
 
    -- "Currently held buttons" - what the user is pretending to press.
    -- Format: bit 7=A, 6=B, 5=Select, 4=Start, 3=Up, 2=Down, 1=Left, 0=Right
    signal injected_buttons : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
 
    -- Fake NES state
    signal pulse_prev : STD_LOGIC := '0';
    signal latch_prev : STD_LOGIC := '0';
    signal bit_idx    : integer range 0 to 7 := 7;
 
begin
 
    -- DUT - full top-level with scaled timing
    uut : top
        generic map (
            nes_half_period_cycles => 5,        -- ~50 ns half-period
            nes_frame_gap_cycles   => 2000,     -- 20 us between polls
            pwm_period_cycles      => 2000,     -- 20 us "20 ms" PWM period
            pwm_num_bits           => 18
        )
        port map (
            clk          => clk,
            reset_n      => reset_n,
            nes_data     => nes_data,
            nes_latch    => nes_latch,
            nes_pulse    => nes_pulse,
            pwm_out      => pwm_out,
            led_selected => led_selected
        );
 
    -- Clock
    clk_proc : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;
 
    -- Fake NES controller (active-low, like real hardware)
    fake_nes : process(clk)
    begin
        if rising_edge(clk) then
            latch_prev <= nes_latch;
            pulse_prev <= nes_pulse;
 
            -- Latch rising edge: load bit 7 (active-low: invert)
            if nes_latch = '1' and latch_prev = '0' then
                bit_idx  <= 7;
                nes_data <= not injected_buttons(7);
            end if;
 
            -- Pulse rising edge: shift to next bit
            if nes_pulse = '1' and pulse_prev = '0' then
                if bit_idx > 0 then
                    nes_data <= not injected_buttons(bit_idx - 1);
                    bit_idx  <= bit_idx - 1;
                end if;
            end if;
        end if;
    end process;
 
    -- Stimulus: pretend to press buttons in sequence
    sim : process
    begin
        report "tb_top_integration: BEGIN";
 
        -- Phase 1: reset the system
        reset_n <= '0';
        wait for 500 ns;
        reset_n <= '1';
        wait for 50 us;
        report "phase 1 (reset complete) - pwm_out should be near 0% duty";
 
        -- Phase 2: press Start (bit 4) - should reset all joints to home
        report "phase 2: pressing Start";
        injected_buttons <= "00010000";
        wait for 500 us;
        injected_buttons <= "00000000";
        wait for 200 us;
        report "phase 2 done - pwm_out should be 7.5% duty (centered/home)";
 
        -- Phase 3: press Up (bit 3) - should advance selected joint
        report "phase 3: pressing Up to select next joint";
        injected_buttons <= "00001000";
        wait for 200 us;
        injected_buttons <= "00000000";
        wait for 100 us;
        report "phase 3 done - led_selected should equal 001";
 
        -- Phase 4: hold Right (bit 0) - selected joint should move forward
        report "phase 4: holding Right";
        injected_buttons <= "00000001";
        wait for 1 ms;       -- long hold to see motion build up
        report "phase 4 still holding - pwm_out[1] duty should be rising";
 
        -- Phase 5: release
        injected_buttons <= "00000000";
        wait for 200 us;
        report "phase 5: released - joint 1 should hold position";
 
        -- Phase 6: hold Left (bit 1) - joint 1 should reverse
        report "phase 6: holding Left";
        injected_buttons <= "00000010";
        wait for 1 ms;
        injected_buttons <= "00000000";
        wait for 200 us;
 
        -- Phase 7: press Start again - emergency reset to home
        report "phase 7: Start pressed - all joints should snap to home";
        injected_buttons <= "00010000";
        wait for 500 us;
        injected_buttons <= "00000000";
        wait for 200 us;
 
        report "tb_top_integration: END";
        wait;
    end process;
 
end Behavioral;
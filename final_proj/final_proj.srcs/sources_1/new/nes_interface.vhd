----------------------------------------------------------------------------------
-- Module Name: nes_interface - Behavioral
-- Description: NES controller serial protocol interface.  Generates the latch
--              and pulse signals the controller expects, then samples the data
--              line eight times to capture all eight buttons.
--
-- Protocol timing:
--   1. Latch goes HIGH for ~12 us (doLatch) -- controller loads parallel state
--   2. Latch goes LOW; controller presents bit 7 (A) on data
--   3. Wait one half-period for data to settle (postLatchWait)
--   4. Sample data line -> capture bit 7
--   5. Pulse rising edge tells controller to shift to next bit
--   6. Pulse low, wait, sample bit 6
--   7. Repeat for bits 5, 4, 3, 2, 1, 0
--
-- Captured byte order (MSB first):
--   shift_reg(7) = A     shift_reg(3) = Up
--   shift_reg(6) = B     shift_reg(2) = Down
--   shift_reg(5) = Sel   shift_reg(1) = Left
--   shift_reg(4) = Start shift_reg(0) = Right
--
-- This file contains TWO iterations.  Only one is active at a time.
--
--   ACTIVE (below):    Final version with the postLatchWait state, used for
--                      the button-mapping demo.  All eight buttons captured
--                      correctly including Right.
--
--   COMMENTED OUT:     Earlier iteration (functionally equivalent now).
--                      Kept as a debugging fallback in case timing on a
--                      different board needs a different settle window.
----------------------------------------------------------------------------------


-- ===================================================================
-- ALTERNATE: earlier iteration (commented out)
-- ===================================================================

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity nes_interface is
--    generic (
--           half_period_cycles : integer := 1200;
--           frame_gap_cycles : integer := 1600000
--    );
--    port ( clk : in STD_LOGIC;
--           reset_n : in STD_LOGIC;
--           nes_data : in STD_LOGIC;
--           nes_latch : out STD_LOGIC;
--           nes_pulse : out STD_LOGIC;
--           button_state : out std_logic_vector(7 downto 0));
--end nes_interface;

--architecture Behavioral of nes_interface is
--    -- Added postLatchWait between doLatch and first sampleBit
--    type state_t is (waitFrame, doLatch, postLatchWait, sampleBit, pulseHigh, pulseLow, done);
--    signal state : state_t := waitFrame;

--    signal frame_cnt : unsigned(20 downto 0) := (others => '0');
--    signal clk_cnt : unsigned(10 downto 0) := (others => '0');
--    signal bit_cnt : unsigned(3 downto 0) := (others => '0');
--    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
--    signal latched_buttons : std_logic_vector(7 downto 0) := (others => '0');

--    signal i_latch, i_pulse : std_logic := '0';
--begin

--    state_process : process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                state <= waitFrame;
--                frame_cnt <= (others => '0');
--                clk_cnt <= (others => '0');
--                bit_cnt <= (others => '0');
--                shift_reg <= (others => '0');
--                latched_buttons <= (others => '0');
--            else
--                case state is
--                    when waitFrame =>
--                        if frame_cnt = to_unsigned(frame_gap_cycles - 1, frame_cnt'length) then
--                            frame_cnt <= (others => '0');
--                            bit_cnt <= (others => '0');
--                            shift_reg <= (others => '0');
--                            state <= doLatch;
--                        else
--                            frame_cnt <= frame_cnt + 1;
--                        end if;

--                    when doLatch =>
--                        -- Latch is high. Controller loads parallel state, presents bit 7 on data.
--                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
--                            clk_cnt <= (others => '0');
--                            state <= postLatchWait;
--                        else
--                            clk_cnt <= clk_cnt + 1;
--                        end if;

--                    when postLatchWait =>
--                        -- Latch has just fallen. Wait one half-period for data line
--                        -- to settle to bit 7 (A) before sampling.  This was the bug:
--                        -- previously we sampled immediately and missed bit 7.
--                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
--                            clk_cnt <= (others => '0');
--                            state <= sampleBit;
--                        else
--                            clk_cnt <= clk_cnt + 1;
--                        end if;

--                    when sampleBit =>
--                        -- Sample current data line value (active-low: pressed = 0V)
--                        shift_reg <= shift_reg(6 downto 0) & (not nes_data);

--                        if bit_cnt = to_unsigned(7, bit_cnt'length) then
--                            state <= done;
--                        else
--                            state <= pulseHigh;
--                        end if;

--                    when pulseHigh =>
--                        -- Pulse high.  Rising edge tells controller to shift to next bit.
--                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
--                            clk_cnt <= (others => '0');
--                            state <= pulseLow;
--                        else
--                            clk_cnt <= clk_cnt + 1;
--                        end if;

--                    when pulseLow =>
--                        -- Pulse low.  Wait for new data to appear, then sample.
--                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
--                            clk_cnt <= (others => '0');
--                            bit_cnt <= bit_cnt + 1;
--                            state <= sampleBit;
--                        else
--                            clk_cnt <= clk_cnt + 1;
--                        end if;

--                    when done =>
--                        latched_buttons <= shift_reg;
--                        state <= waitFrame;
--                end case;
--            end if;
--        end if;
--    end process;

--    i_latch <= '1' when state = doLatch else '0';
--    i_pulse <= '1' when state = pulseHigh else '0';

--    nes_latch <= i_latch;
--    nes_pulse <= i_pulse;
--    button_state <= latched_buttons;

--end Behavioral;


-- ===================================================================
-- ACTIVE: button-mapping demo
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity nes_interface is
    generic (
           half_period_cycles : integer := 1200;
           frame_gap_cycles : integer := 1600000
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           nes_data : in STD_LOGIC;
           nes_latch : out STD_LOGIC;
           nes_pulse : out STD_LOGIC;
           button_state : out std_logic_vector(7 downto 0));
end nes_interface;

architecture Behavioral of nes_interface is
    -- Added postLatchWait between doLatch and first sampleBit
    type state_t is (waitFrame, doLatch, postLatchWait, sampleBit, pulseHigh, pulseLow, done);
    signal state : state_t := waitFrame;

    signal frame_cnt : unsigned(20 downto 0) := (others => '0');
    signal clk_cnt : unsigned(10 downto 0) := (others => '0');
    signal bit_cnt : unsigned(3 downto 0) := (others => '0');
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal latched_buttons : std_logic_vector(7 downto 0) := (others => '0');

    signal i_latch, i_pulse : std_logic := '0';
begin

    state_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= waitFrame;
                frame_cnt <= (others => '0');
                clk_cnt <= (others => '0');
                bit_cnt <= (others => '0');
                shift_reg <= (others => '0');
                latched_buttons <= (others => '0');
            else
                case state is
                    when waitFrame =>
                        if frame_cnt = to_unsigned(frame_gap_cycles - 1, frame_cnt'length) then
                            frame_cnt <= (others => '0');
                            bit_cnt <= (others => '0');
                            shift_reg <= (others => '0');
                            state <= doLatch;
                        else
                            frame_cnt <= frame_cnt + 1;
                        end if;

                    when doLatch =>
                        -- Latch is high. Controller loads parallel state, presents bit 7 on data.
                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
                            clk_cnt <= (others => '0');
                            state <= postLatchWait;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when postLatchWait =>
                        -- Latch has just fallen. Wait one half-period for data line
                        -- to settle to bit 7 (A) before sampling.  This was the bug:
                        -- previously we sampled immediately and missed bit 7.
                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
                            clk_cnt <= (others => '0');
                            state <= sampleBit;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when sampleBit =>
                        -- Sample current data line value (active-low: pressed = 0V)
                        shift_reg <= shift_reg(6 downto 0) & (not nes_data);

                        if bit_cnt = to_unsigned(7, bit_cnt'length) then
                            state <= done;
                        else
                            state <= pulseHigh;
                        end if;

                    when pulseHigh =>
                        -- Pulse high.  Rising edge tells controller to shift to next bit.
                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
                            clk_cnt <= (others => '0');
                            state <= pulseLow;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when pulseLow =>
                        -- Pulse low.  Wait for new data to appear, then sample.
                        if clk_cnt = to_unsigned(half_period_cycles - 1, clk_cnt'length) then
                            clk_cnt <= (others => '0');
                            bit_cnt <= bit_cnt + 1;
                            state <= sampleBit;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when done =>
                        latched_buttons <= shift_reg;
                        state <= waitFrame;
                end case;
            end if;
        end if;
    end process;

    i_latch <= '1' when state = doLatch else '0';
    i_pulse <= '1' when state = pulseHigh else '0';

    nes_latch <= i_latch;
    nes_pulse <= i_pulse;
    button_state <= latched_buttons;

end Behavioral;
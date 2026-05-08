----------------------------------------------------------------------------------
-- Testbench: tb_nes_interface
-- Purpose: Verify nes_interface generates correct latch/pulse and decodes data.
--
-- IMPORTANT: real NES controllers are ACTIVE-LOW on the data line.
-- Pressed=0V, Released=3.3V. Your nes_interface inverts (`not nes_data`)
-- to convert that to "1 = pressed" internally. So this fake controller
-- must drive data ACTIVE-LOW too:
--   - test_pattern bit = '1' (pressed)  ->  drive nes_data = '0'
--   - test_pattern bit = '0' (released) ->  drive nes_data = '1'
--
-- Test sequence:
--   - Latch rising edge: load bit 7 onto data
--   - Pulse rising edge: advance to next bit
--   - After 8 bits, button_state should equal test_pattern
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_nes_interface is
end tb_nes_interface;

architecture Behavioral of tb_nes_interface is
    component nes_interface is
        generic (
            half_period_cycles : integer := 1200;
            frame_gap_cycles   : integer := 1600000
        );
        port (
            clk          : in  STD_LOGIC;
            reset_n      : in  STD_LOGIC;
            nes_data     : in  STD_LOGIC;
            nes_latch    : out STD_LOGIC;
            nes_pulse    : out STD_LOGIC;
            button_state : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    constant clk_period : time := 10 ns;

    signal clk          : STD_LOGIC := '0';
    signal reset_n      : STD_LOGIC := '0';
    signal nes_data     : STD_LOGIC := '1';  -- idle high (no buttons pressed)
    signal nes_latch    : STD_LOGIC;
    signal nes_pulse    : STD_LOGIC;
    signal button_state : STD_LOGIC_VECTOR(7 downto 0);

    -- Pattern we want the FPGA to capture.  bit 7 = A, bit 0 = Right.
    -- "10000001" means A pressed and Right pressed.
    constant test_pattern : STD_LOGIC_VECTOR(7 downto 0) := "10000001";

    signal pulse_prev : STD_LOGIC := '0';
    signal latch_prev : STD_LOGIC := '0';
    signal bit_idx    : integer range 0 to 7 := 7;

begin

    -- DUT with scaled timing for fast sim
    uut : nes_interface
        generic map (
            half_period_cycles => 5,        -- 50 ns half-period (vs 12 us real)
            frame_gap_cycles   => 2000      -- 20 us gap (vs 16 ms real)
        )
        port map (
            clk          => clk,
            reset_n      => reset_n,
            nes_data     => nes_data,
            nes_latch    => nes_latch,
            nes_pulse    => nes_pulse,
            button_state => button_state
        );

    -- Clock
    clk_proc : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Fake NES controller (active-low, like real hardware).
    -- On latch rising edge: present bit 7 (inverted, since active-low).
    -- On pulse rising edge: advance to next bit.
    fake_nes : process(clk)
    begin
        if rising_edge(clk) then
            latch_prev <= nes_latch;
            pulse_prev <= nes_pulse;

            -- Latch rising edge: load bit 7
            if nes_latch = '1' and latch_prev = '0' then
                bit_idx  <= 7;
                -- Active-low: invert the pattern bit
                nes_data <= not test_pattern(7);
            end if;

            -- Pulse rising edge: shift to next bit
            if nes_pulse = '1' and pulse_prev = '0' then
                if bit_idx > 0 then
                    nes_data <= not test_pattern(bit_idx - 1);
                    bit_idx  <= bit_idx - 1;
                end if;
            end if;
        end if;
    end process;

    -- Stimulus + check
    sim : process
    begin
        report "tb_nes_interface: starting";
        reset_n <= '0';
        wait for 200 ns;
        reset_n <= '1';

        -- Wait long enough for at least 2 polling frames to complete.
        -- Each frame at scaled timing is ~2 us setup + ~8*200ns shifting = ~5 us
        -- Plus 20 us frame_gap_cycles wait.  100 us covers several frames.
        wait for 100 us;

        -- Check the result
        if button_state = test_pattern then
            report "tb_nes_interface: PASS - button_state = " &
                   integer'image(to_integer(unsigned(button_state)));
        else
            report "tb_nes_interface: FAIL - expected " &
                   integer'image(to_integer(unsigned(test_pattern))) &
                   " got " &
                   integer'image(to_integer(unsigned(button_state))) & ""
                severity error;
        end if;

        wait;
    end process;

end Behavioral;
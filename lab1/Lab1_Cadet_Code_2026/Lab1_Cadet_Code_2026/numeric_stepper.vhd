-- Numeric Stepper: Holds a value and increments or decrements it based on button presses
-- James Trimble, 20 Jan 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity numeric_stepper is
  generic (
    num_bits  : integer := 8;
    max_value : integer := 127;
    min_value : integer := -128;
    delta     : integer := 10
  );
  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
end numeric_stepper;

architecture numeric_stepper_arch of numeric_stepper is
  signal process_q : signed(num_bits-1 downto 0) := to_signed(min_value,num_bits);
  signal prev_up, prev_down : std_logic := '0';

  constant CLK_HZ : integer := 100000000;
  constant DEBOUNCE_TICKS : integer := CLK_HZ / 50;
  signal db_cnt : integer range 0 to DEBOUNCE_TICKS := 0;

  signal do_inc, do_dec : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then

      -- default each cycle
      do_inc <= '0';
      do_dec <= '0';

      if reset_n = '0' then
        process_q <= to_signed(min_value, num_bits);
        prev_up   <= '0';
        prev_down <= '0';
        db_cnt    <= 0;

      else
        -- debounce counter
        if db_cnt > 0 then
          db_cnt <= db_cnt - 1;
        end if;

        -- detect rising edge presses (only if debounce expired)
        if en = '1' and db_cnt = 0 then
          if up = '1' and prev_up = '0' and down = '0' then
            do_inc <= '1';
            db_cnt <= DEBOUNCE_TICKS;
          elsif down = '1' and prev_down = '0' and up = '0' then
            do_dec <= '1';
            db_cnt <= DEBOUNCE_TICKS;
          end if;
        end if;

        -- update value
        if do_inc = '1' then
          process_q <= process_q + to_signed(delta, num_bits);
        elsif do_dec = '1' then
          process_q <= process_q - to_signed(delta, num_bits);
        end if;

        prev_up   <= up;
        prev_down <= down;
      end if;

    end if;
  end process;

  q <= process_q;

end numeric_stepper_arch;


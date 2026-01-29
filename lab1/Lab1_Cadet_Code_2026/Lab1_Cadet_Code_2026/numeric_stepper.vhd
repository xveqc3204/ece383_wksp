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
    signal is_increment, is_decrement : boolean := false;
    
    --Documentation: C2C Metwally helped me understand debouncing and general concepts surrounding this implementation
    --100 MHz, 2,000,000 cycles = 0.02 s = 20 ms window where not accepting inputs
    constant CLK_HZ : integer := 100000000;          
    constant DEBOUNCE_TICKS : integer := CLK_HZ / 50;  
    signal db_cnt : integer range 0 to DEBOUNCE_TICKS := 0;
    
begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
        
            -- debounce counter
            if reset_n = '0' then
                db_cnt <= 0;
            elsif db_cnt > 0 then
                db_cnt <= db_cnt - 1;
            end if;
            
            --db_cnt is included to ensure first input is only input for the next 20ms
            is_increment <= true when (en = '1' and db_cnt = 0 and up = '1' and prev_up = '0' and down = '0') else false;
            is_decrement <= true when (en = '1' and db_cnt = 0 and down = '1' and prev_down = '0' and up = '0') else false;
            
            process_q <= to_signed(min_value, num_bits) when reset_n = '0' else
                         signed(process_q) + signed(to_signed(delta, num_bits)) when is_increment else
                         signed(process_q) - signed(to_signed(delta, num_bits)) when is_decrement else
                         process_q;
 
            -- start debounce cooldown after press
            if reset_n = '1' then
                if is_increment or is_decrement then
                    db_cnt <= DEBOUNCE_TICKS;
                end if;
            end if;             
                         
            prev_up   <= '0' when reset_n = '0' else up;
            prev_down <= '0' when reset_n = '0' else down;
                
        end if;   
    end process;
    
q <= process_q;

end numeric_stepper_arch;

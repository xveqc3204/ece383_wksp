----------------------------------------------------------------------------------
-- Module Name: pwm_gen - Behavioral
-- Description: Six-channel PWM generator. One shared 21-bit period counter
--              drives six parallel comparators, one per joint. Period defaults
--              to 20 ms (50 Hz) at 100 MHz, which is the standard hobby-servo
--              control rate.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pwm_gen is
    generic (
           period_cycles : integer := 2000000;
           num_bits : integer := 18
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           cmd_0 : in unsigned(num_bits-1 downto 0);
           cmd_1 : in unsigned(num_bits-1 downto 0);
           cmd_2 : in unsigned(num_bits-1 downto 0);
           cmd_3 : in unsigned(num_bits-1 downto 0);
           cmd_4 : in unsigned(num_bits-1 downto 0);
           cmd_5 : in unsigned(num_bits-1 downto 0);
           pwm_out : out std_logic_vector(5 downto 0));
end pwm_gen;

architecture Behavioral of pwm_gen is
    constant MAX_COUNT : unsigned(20 downto 0) := to_unsigned(period_cycles - 1, 21);
    signal counter : unsigned(20 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                counter <= (others => '0');
            elsif counter = MAX_COUNT then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- each channel compares the shared period counter against its commanded pulse width
    -- zero-extend cmd from 18 bits up to the 21-bit counter
    pwm_out(0) <= '1' when (counter < resize(cmd_0, 21)) else '0';
    pwm_out(1) <= '1' when (counter < resize(cmd_1, 21)) else '0';
    pwm_out(2) <= '1' when (counter < resize(cmd_2, 21)) else '0';
    pwm_out(3) <= '1' when (counter < resize(cmd_3, 21)) else '0';
    pwm_out(4) <= '1' when (counter < resize(cmd_4, 21)) else '0';
    pwm_out(5) <= '1' when (counter < resize(cmd_5, 21)) else '0';

end Behavioral;
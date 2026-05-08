----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 02:48:32 PM
-- Design Name: 
-- Module Name: tb_pwm_gen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_pwm_gen is
--  Port ( );
end tb_pwm_gen;

architecture Behavioral of tb_pwm_gen is
    component pwm_gen is
        generic (
            period_cycles : integer := 2000000;
            num_bits : integer := 18
        );
        port (
            clk     : in  STD_LOGIC;
            reset_n : in  STD_LOGIC;
            cmd_0   : in  unsigned(num_bits-1 downto 0);
            cmd_1   : in  unsigned(num_bits-1 downto 0);
            cmd_2   : in  unsigned(num_bits-1 downto 0);
            cmd_3   : in  unsigned(num_bits-1 downto 0);
            cmd_4   : in  unsigned(num_bits-1 downto 0);
            cmd_5   : in  unsigned(num_bits-1 downto 0);
            pwm_out : out STD_LOGIC_VECTOR(5 downto 0)
        );
    end component;
 
    constant clk_period : time := 10 ns;  -- 100 MHz
 
    signal clk     : STD_LOGIC := '0';
    signal reset_n : STD_LOGIC := '0';
    signal cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5 : unsigned(17 downto 0)
            := (others => '0');
    signal pwm_out : STD_LOGIC_VECTOR(5 downto 0);
 
begin
 
    -- DUT: scaled period so simulation finishes quickly
    -- 2000 cycles instead of 2,000,000 = 20 us simulated "20 ms" period
    uut : pwm_gen
        generic map (period_cycles => 2000, num_bits => 18)
        port map (
            clk => clk, reset_n => reset_n,
            cmd_0 => cmd_0, cmd_1 => cmd_1, cmd_2 => cmd_2,
            cmd_3 => cmd_3, cmd_4 => cmd_4, cmd_5 => cmd_5,
            pwm_out => pwm_out
        );
 
    -- 100 MHz clock generator
    clk_proc : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;
 
    -- Stimulus
    sim : process
    begin
        report "tb_pwm_gen: starting simulation";
 
        -- Hold in reset for 100 ns
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
 
        -- Apply test values: scaled 1ms / 1.5ms / 2ms plus 3 sanity values
        cmd_0 <= to_unsigned(100,  18);  -- 1.0 ms equivalent (full CCW)
        cmd_1 <= to_unsigned(150,  18);  -- 1.5 ms equivalent (HOME)
        cmd_2 <= to_unsigned(200,  18);  -- 2.0 ms equivalent (full CW)
        cmd_3 <= to_unsigned(0,    18);  -- always low (sanity)
        cmd_4 <= to_unsigned(1000, 18);  -- 50% duty (sanity)
        cmd_5 <= to_unsigned(2000, 18);  -- always high (sanity, edge case)
 
        -- Let it run for ~3 full periods so you can see repetition
        wait for 60 us;
 
        -- Now change one cmd mid-flight to verify it takes effect on the
        -- next period boundary (this is what happens during real button presses)
        report "tb_pwm_gen: changing cmd_0 to 200 to verify mid-flight update";
        cmd_0 <= to_unsigned(200, 18);
        wait for 60 us;
 
        report "tb_pwm_gen: simulation complete";
        wait;
    end process;
 
end Behavioral;
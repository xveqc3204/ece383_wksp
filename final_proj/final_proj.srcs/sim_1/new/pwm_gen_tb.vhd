----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2026 08:29:17 AM
-- Design Name: 
-- Module Name: pwm_gen_tb - Behavioral
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

entity pwm_gen_tb is
--  Port ( );
end pwm_gen_tb;

architecture Behavioral of pwm_gen_tb is

component pwm_gen
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
end component;

signal clk : STD_LOGIC := '0';
signal reset_n : STD_LOGIC := '0';
signal cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5 : unsigned(17 downto 0) := (others => '0');
signal pwm_out : std_logic_vector(5 downto 0);

constant period : time := 10 ns;

begin

    -- shorten the PWM period 1000x so simulation finishes in reasonable time.
    -- ratios between pulse widths stay the same so behavior is identical.
    uut : pwm_gen
    generic map (
        period_cycles => 2000,
        num_bits => 18
    )
    port map (
        clk => clk,
        reset_n => reset_n,
        cmd_0 => cmd_0,
        cmd_1 => cmd_1,
        cmd_2 => cmd_2,
        cmd_3 => cmd_3,
        cmd_4 => cmd_4,
        cmd_5 => cmd_5,
        pwm_out => pwm_out
    );

    clk_process : process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

    sim : process
    begin
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';

        -- 100/150/200 cycles = scaled 1.0/1.5/2.0 ms equivalents
        cmd_0 <= to_unsigned(100, 18);
        cmd_1 <= to_unsigned(150, 18);
        cmd_2 <= to_unsigned(200, 18);
        cmd_3 <= to_unsigned(0, 18);
        cmd_4 <= to_unsigned(1000, 18);
        cmd_5 <= to_unsigned(2000, 18);

        wait for 50 us;
        wait;
    end process;

end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2026 08:31:10 PM
-- Design Name: 
-- Module Name: hw4_tb - Behavioral
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

entity hw4_tb is
--  Port ( );
end hw4_tb;

architecture Behavioral of hw4_tb is

component counter 
    generic (
           num_bits : integer := 4;
           max_value : integer := 9
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC;
           roll : out STD_LOGIC;
           Q : out unsigned (num_bits-1 downto 0));
end component;

signal clk : STD_LOGIC := '0';
signal reset_n : STD_LOGIC := '1';
signal ctrl : STD_LOGIC := '0';   
signal roll_lsb : STD_LOGIC;  
signal roll_msb : STD_LOGIC;     
signal Q0 : unsigned(3 downto 0); 
signal Q1 : unsigned(3 downto 0); 

constant period : time := 10 ns; 

begin

    clk_process : process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;
    
        lsb_counter : counter
        generic map (
            num_bits => 4,
            max_value => 9
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            ctrl => ctrl,
            roll => roll_lsb,
            Q => Q0        
            );
        
        msb_counter : counter
        generic map (
            num_bits => 4,
            max_value => 9
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            ctrl => roll_lsb,
            roll => roll_msb,
            Q => Q1
        );
       
        reset_n <= '0', '1' after 20 ns;
        
        ctrl <= '1' after 30 ns, '0' after 70 ns, '1' after 80 ns, '0' after 150 ns, '1' after 160 ns, '0' after 170 ns, '1' after 180 ns;

end Behavioral;
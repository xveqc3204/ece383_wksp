----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2026 04:22:35 PM
-- Design Name: 
-- Module Name: hw3_tb - Behavioral
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

entity hw3_tb is
--  Port ( );
end hw3_tb;

architecture Behavioral of hw3_tb is
COMPONENT hw3  
    PORT( 
        d : IN unsigned(7 downto 0);
        h : OUT std_logic
        );
END COMPONENT;

signal ds : unsigned(7 downto 0);
signal hs : std_logic;

begin

    uut : hw3
    Port Map (
        d => ds,
        h => hs
    );
    
    sim : process
    begin
        for i in 1 to 51 loop
            ds <= to_unsigned(i, 8);
            wait for 10 ns;
        end loop;
        wait;
    end process;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2026 08:05:20 AM
-- Design Name: 
-- Module Name: flag_register - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flag_register is
    Port ( clk: in std_logic;
           reset_n: in std_logic;
           set: in std_logic;
           clear: in std_logic;
           Q: out std_logic
          );
end flag_register;

architecture Behavioral of flag_register is
    signal nextQ, currentQ: std_logic := '0';
begin
    process(clk) 
        begin
        if(rising_edge(clk)) then
           if(reset_n = '0') then 
                nextQ <= '0';
           elsif(set = '0' and clear = '1') then 
                nextQ <= '0';
           elsif(set = '1' and clear = '0') then 
                nextQ <= '1';
           else 
                nextQ <= currentQ;                        
           end if; 
        
        end if;
        end process;
    currentQ <= nextQ;
    Q <= currentQ; 
end Behavioral;

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
    Port ( set : in STD_LOGIC;
           clear : in STD_LOGIC;
           Q : out STD_LOGIC);
end flag_register;

architecture Behavioral of flag_register is

begin

	process (clk)
	begin
		if (rising_edge(clk)) then
			if reset_n = '0' then
            flag
			elsif(sw_ready = '1') then
			
			end if;
		end if;
	end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 08:58:39 PM
-- Design Name: 
-- Module Name: scancode_decoder - Behavioral
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

entity scancode_decoder is
    Port ( scancode : in STD_LOGIC_VECTOR (7 downto 0);
           decoded_value : out STD_LOGIC_VECTOR (3 downto 0));
end scancode_decoder;

architecture Behavioral of scancode_decoder is
begin
    decoded_value <= "0000" when scancode = x"45" else
                     "0001" when scancode = x"16" else
                     "0010" when scancode = x"1E" else
                     "0011" when scancode = x"26" else
                     "0100" when scancode = x"25" else
                     "0101" when scancode = x"2E" else
                     "0110" when scancode = x"36" else
                     "0111" when scancode = x"3D" else
                     "1000" when scancode = x"3E" else
                     "1001" when scancode = x"46" else
                     "1111"; -- default aside case 
end Behavioral;

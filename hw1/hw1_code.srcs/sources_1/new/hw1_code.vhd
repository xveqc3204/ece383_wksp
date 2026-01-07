----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2026 04:06:43 PM
-- Design Name: 
-- Module Name: hw1_code - Behavioral
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

entity priority_encoder is
   Port ( 
    I3 : in std_logic;
    I2 : in std_logic;
    I1 : in std_logic;
    I0 : in std_logic;
    O1 : out std_logic;
    O0 : out std_logic
    );
end priority_encoder;

architecture Behavioral of priority_encoder is
begin
    O1 <= I2 OR I3;
    O0 <= I3 OR (NOT(I2) AND I1);
end Behavioral;

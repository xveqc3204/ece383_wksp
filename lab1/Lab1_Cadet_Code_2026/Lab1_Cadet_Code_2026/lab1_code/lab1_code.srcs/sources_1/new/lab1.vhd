----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/21/2026 08:48:54 AM
-- Design Name: 
-- Module Name: lab1 - Behavioral
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

entity lab1 is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           tmds : out STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out STD_LOGIC_VECTOR (3 downto 0);
           sw : in STD_LOGIC_VECTOR (1 downto 0));   
end lab1;

architecture structure of lab1 is

    signal trigger_time, trigger_volt, row, column: unsigned(9 downto 0);
    signal triggerVolt, triggerTime, writeCnter: unsigned(9 downto 0);
    signal old_button, buttonActivity: std_logic_vector(4 downto 0);
    signal ch1_wave, ch2_wave: std_logic;

    component video component is 
    
begin


end structure;

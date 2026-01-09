----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 08:58:39 PM
-- Design Name: 
-- Module Name: scancode_decoder_tb - Behavioral
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

entity scancode_decoder_tb is
--  Port ( );
end scancode_decoder_tb;

architecture Behavioral of scancode_decoder_tb is
COMPONENT scancode_decoder  
    PORT( 
        scancode : IN std_logic_vector(7 downto 0);
        decoded_value : OUT std_logic_vector(3 downto 0)
        );
END COMPONENT;

signal s : std_logic_vector(7 downto 0);
signal d : std_logic_vector(3 downto 0);

begin
    uut : scancode_decoder
    Port Map (
        scancode => s,        
        decoded_value => d
    );
    sim : process
    begin
       s <= x"45"; wait for 10 ns;
       assert (d = "0000") report "FAILED: 0000 case" severity failure;
       s <= x"16"; wait for 10 ns;
       assert (d = "0001") report "FAILED: 0001 case" severity failure;
       s <= x"1E"; wait for 10 ns;
       assert (d = "0010") report "FAILED: 0010 case" severity failure;
       s <= x"26"; wait for 10 ns;
       assert (d = "0011") report "FAILED: 0011 case" severity failure;
       s <= x"25"; wait for 10 ns;
       assert (d = "0100") report "FAILED: 0100 case" severity failure;
       s <= x"2E"; wait for 10 ns;
       assert (d = "0101") report "FAILED: 0101 case" severity failure;
       s <= x"36"; wait for 10 ns;
       assert (d = "0110") report "FAILED: 0110 case" severity failure;        
       s <= x"3D"; wait for 10 ns;
       assert (d = "0111") report "FAILED: 0111 case" severity failure;        
       s <= x"3E"; wait for 10 ns;
       assert (d = "1000") report "FAILED: 1000 case" severity failure;
       s <= x"46"; wait for 10 ns;
       assert (d = "1001") report "FAILED: 1001 case" severity failure;
       wait;
    end process;
    
end Behavioral;
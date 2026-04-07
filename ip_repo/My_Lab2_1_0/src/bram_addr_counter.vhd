----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2026 08:31:10 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity bram_addr_counter is
    generic (
        num_bits  : integer := 10
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC_VECTOR(1 downto 0);
           D : in  unsigned(num_bits-1 downto 0);
           Q : out unsigned (num_bits-1 downto 0));
end bram_addr_counter;

architecture Behavioral of bram_addr_counter is
    signal processQ : unsigned(num_bits-1 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
          processQ <= (others => '0');
      else 
      --Looked up switch case syntax using online resources
          case ctrl is
            when "00" =>
                null; --found online, another way to hold
            when "01" => --count
                processQ <= processQ + 1;
            when "10" => -- load
                processQ <= unsigned(D);
            when "11" =>
                processQ <= (others => '0');
            when others =>
                null;
           end case;
        end if;
      end if;
    end process;

  Q <= processQ;

end Behavioral;
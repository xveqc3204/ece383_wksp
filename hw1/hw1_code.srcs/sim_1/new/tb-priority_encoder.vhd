----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 09:21:01 AM
-- Design Name: 
-- Module Name: tb_priority_encoder - Behavioral
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

entity tb_priority_encoder is
--  Port ( );
end tb_priority_encoder;

architecture Behavioral of tb_priority_encoder is
COMPONENT priority_encoder
    PORT( I3 : IN std_logic;
          I2 : IN std_logic;
          I1 : IN std_logic;
          I0 : IN std_logic;
          O1 : out std_logic;
          O0 : out std_logic
    );
END COMPONENT;

signal I3, I2, I1, I0 : std_logic := '0';
signal O1, O0 : std_logic;

begin
    uut : priority_encoder
    Port Map (
        I3 => I3,
        I2 => I2,
        I1 => I1,
        I0 => I0,
        O1 => O1,
        O0 => O0
     );
     
     sim : process
     begin 
     -- Dont test don't care case '0000'
        I3 <= '0'; I2 <= '0'; I1 <= '0'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '0' and O0 = '0') report "FAILED: 0001 case" severity failure;
        I3 <= '0'; I2 <= '0'; I1 <= '1'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '0' and O0 = '1') report "FAILED: 0010 case" severity failure;
        I3 <= '0'; I2 <= '0'; I1 <= '1'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '0' and O0 = '1') report "FAILED: 0011 case" severity failure;
        I3 <= '0'; I2 <= '1'; I1 <= '0'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '0') report "FAILED: 0100 case" severity failure;
        I3 <= '0'; I2 <= '1'; I1 <= '0'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '0') report "FAILED: 0101 case" severity failure;
        I3 <= '0'; I2 <= '1'; I1 <= '1'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '0') report "FAILED: 0110 case" severity failure;
        I3 <= '0'; I2 <= '1'; I1 <= '1'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '0') report "FAILED: 0111 case" severity failure;
        I3 <= '1'; I2 <= '0'; I1 <= '0'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1000 case" severity failure;
        I3 <= '1'; I2 <= '0'; I1 <= '0'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1001 case" severity failure;
        I3 <= '1'; I2 <= '0'; I1 <= '1'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1010 case" severity failure;
        I3 <= '1'; I2 <= '0'; I1 <= '1'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1011 case" severity failure;
        I3 <= '1'; I2 <= '1'; I1 <= '0'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1100 case" severity failure;
        I3 <= '1'; I2 <= '1'; I1 <= '0'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1101 case" severity failure;
        I3 <= '1'; I2 <= '1'; I1 <= '1'; I0 <= '0'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1110 case" severity failure;
        I3 <= '1'; I2 <= '1'; I1 <= '1'; I0 <= '1'; wait for 10 ns;
            assert (O1 = '1' and O0 = '1') report "FAILED: 1111 case" severity failure;
        wait; 
    end process;
        
end Behavioral;

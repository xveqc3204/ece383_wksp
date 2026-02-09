----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/05/2026 03:38:10 PM
-- Design Name: 
-- Module Name: lec11_cu - Behavioral
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

entity lec11_cu is
	Port(	    clk   : in  STD_LOGIC;
                reset : in  STD_LOGIC;       
                kbclk : in  STD_LOGIC;
                cw    : out STD_LOGIC_VECTOR(3 downto 0);
                sw    : in  STD_LOGIC;        
                busy  : out STD_LOGIC);
end lec11_cu;

architecture Behavioral of lec11_cu is

type state_t is (waitStart, init0, waitFall, shiftBits, increment, waitRise, scanBits);
signal state : state_t;

begin

   -----------------------------------------------------------------------
   --    CONTROL UNIT
   -----------------------------------------------------------------------
   state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '0') then 
				state <= waitStart;
			else
				case state is
					when waitStart =>
                        if kbclk = '0' then state <= init0; end if;
					when init0  => 
					    state <= waitFall;
					when waitFall  =>
						if kbclk = '0' then state <= shiftBits; end if;
                    when shiftBits  =>
						state <= increment;		
                    when increment  =>
						state <= waitRise;	
                    when waitRise =>
						if kbclk = '1' then 
						  if sw = '1' then 
						      state <= scanBits; 
						  else
						      state <= waitFall; 
						  end if; 
						end if;	
                    when scanBits  =>
						state <= waitStart;	
				end case;
			end if;
		end if;
	end process;
	
	--Documentation: Used online resources to find not equals syntax /=
    busy <= '1' when (state /= waitStart) else '0';

    cw(3) <= '1' when (state = scanBits) else '0';
    cw(2) <= '1' when (state = shiftBits) else '0';
    cw(1) <= '1' when (state = init0) else '0';
    cw(0) <= '1' when ((state = init0) or (state = increment)) else '0';

end Behavioral;

--------------------------------------------------------------------
-- Name:	George York
-- Date:	Feb 2, 2021
-- File:	button_debounce.vhdl
-- HW:	    Template for HW7
--	Crs:	ECE 383
--
-- Purp:	For this debouncer, we assume the clock is slowed from 100MHz to 100KHz,
--          and the ringing time is less than 20ms
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;		
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;

entity button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
end button_debounce;

architecture behavior of button_debounce is
	
	signal cw: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
	signal sw: STD_LOGIC:= '0';
	type state_type is (resetAction, waitForBtnPress, delay_20msec_1, delay_20msec_2, waitForBtnRelease, activateAction);
	signal state: state_type;
	
	COMPONENT lec10    -- clock for 20 msec debounce delay
		generic (N: integer := 4);
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				crtl: in std_logic_vector(1 downto 0);
				D: in unsigned (N-1 downto 0);
				Q: out unsigned (N-1 downto 0));
    END COMPONENT;
	
	-- these values are for 100KHz
    signal D : unsigned(10 downto 0) := (others => '0');
    signal Q : unsigned(10 downto 0);
    signal less : std_logic := '0';
        
begin
    ----------------------------------------------------------------------
	--   DATAPATH
	----------------------------------------------------------------------
	delay_counter: lec10 
    Generic map(11)
	PORT MAP (
          clk => clk,
          reset => reset,
		  crtl => cw,
          D => D,
          Q => Q
        );	
	
	-- reminder: counter counter every other clock cycle!
   	-- these values are for 100KHz clock
    less <= '1' when (Q < 2000) else '0';
    
   -----------------------------------------------------------------------
   --    CONTROL UNIT
   -----------------------------------------------------------------------
   state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '0') then 
				state <= resetAction;
			else
				case state is
					when resetAction =>
						state <= waitForBtnPress;
					when waitForBtnPress =>
						if (button = '1') then state <= delay_20msec_1; end if;
					when delay_20msec_1 =>
						if (less = '0') then state <= waitForBtnRelease; end if;
                    when waitForBtnRelease =>
						if (button = '0') then state <= delay_20msec_2; end if; 		
                    when delay_20msec_2 =>
						if (less = '0') then state <= activateAction; end if;
                    when activateAction =>
						state <= resetAction;	 	
				end case;
			end if;
		end if;
	end process;


	------------------------------------------------------------------------------
	--			OUTPUT EQUATIONS
	--	
	--		cw is counter control:  00 is hold; 01 is increment; 11 is reset	
	------------------------------------------------------------------------------	
	cw <=   "00" when state = resetAction else
			"11" when state = waitForBtnPress else
			"01" when state = delay_20msec_1 else
			"11" when state = waitForBtnRelease else 
			"01" when state = delay_20msec_2 else
			"00" ;
				
	action <= '1' when state = activateAction else '0';
	
end behavior;
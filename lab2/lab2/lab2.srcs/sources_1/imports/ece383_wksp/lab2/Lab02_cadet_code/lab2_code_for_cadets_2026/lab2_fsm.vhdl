----------------------------------------------------------------------------------
-- Name:	Template by George York (modified from Jeff Falkinburg)
-- Date:	Spring 2023
-- File:    lab2_fsm.vhd
-- HW:	    Lab 2 
-- Pupr:	Lab 2 Finite State Machine for the write circuitry.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lab2_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (2 downto 0);
           cw : out  STD_LOGIC_VECTOR (2 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is
    type state_type is (waitForTrigger, resetCounter, waitForReady, 
                        saveSample, incCounter);
    signal state: state_type := waitForTrigger;
begin
    state_process : process(clk)  
    begin
        if (rising_edge(clk)) then
            if (reset_n = '0') then 
                state <= waitForTrigger;
            else 
                case state is
                    when waitForTrigger =>
                        if sw(2)='1' then  -- trigger crossed
                            state <= resetCounter;
                        end if;
                    when resetCounter =>
                        state <= waitForReady;
                    when waitForReady =>
                        if sw(0)='1' then  -- ready
                            state <= saveSample;
                        end if;
                    when saveSample =>
                        state <= incCounter;
                    when incCounter =>
                        if sw(1)='1' then       -- captured 640 samples
                            state <= waitForTrigger;  -- wait for next trigger
                        else
                            state <= waitForReady;
                        end if;
                end case;
            end if;
        end if;
    end process;
	-------------------------------------------------------------------------------
	--  CW output table
	--		CW		meaning
	--		
	-------------------------------------------------------------------------------
	--    cw_counter_control <= cw(1 downto 0);
    --    cw_write_en <= cw(2);
	
    cw <= "010" when state = resetCounter else  -- ctrl="10" load/ resetCounter
          "000" when state = waitForReady else  -- hold, no write
          "100" when state = saveSample  else   -- write enable
          "001" when state = incCounter  else   -- ctrl="01" count
          "000";   -- waitForTrigger
          
end Behavioral;


----------------------------------------------------------------------------------
-- Module Name: joint_regfile - Behavioral
-- Description: Six 18-bit registers holding the commanded PWM count for each
--              joint.  On reset, each register loads its home value (1.5 ms
--              pulse = 150,000 cycles at 100 MHz) so the arm comes up at a
--              centered pose instead of zero.
--
-- This file contains TWO iterations.  Only one is active at a time.
--
--   ACTIVE (below):    Used for the button-mapping demo.  Resets to home,
--                      writes through sel + wr_en + wr_data.
--
--   COMMENTED OUT:     Earlier iteration (functionally equivalent now).
--                      Kept as a debugging fallback.
----------------------------------------------------------------------------------


-- ===================================================================
-- ALTERNATE: earlier iteration (commented out)
-- ===================================================================

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity joint_regfile is
--    generic (
--        -- home pose values for each joint (must match control_fsm home values)
--        home_0 : integer := 150000;
--        home_1 : integer := 150000;
--        home_2 : integer := 150000;
--        home_3 : integer := 150000;
--        home_4 : integer := 150000;
--        home_5 : integer := 150000   -- gripper centered (was 100000)
--    );
--    port ( clk : in STD_LOGIC;
--           reset_n : in STD_LOGIC;
--           sel : in unsigned(2 downto 0);
--           wr_en : in STD_LOGIC;
--           wr_data : in unsigned(17 downto 0);
--           cmd_0 : out unsigned(17 downto 0);
--           cmd_1 : out unsigned(17 downto 0);
--           cmd_2 : out unsigned(17 downto 0);
--           cmd_3 : out unsigned(17 downto 0);
--           cmd_4 : out unsigned(17 downto 0);
--           cmd_5 : out unsigned(17 downto 0));
--end joint_regfile;

--architecture Behavioral of joint_regfile is
--    signal reg_0 : unsigned(17 downto 0) := to_unsigned(home_0, 18);
--    signal reg_1 : unsigned(17 downto 0) := to_unsigned(home_1, 18);
--    signal reg_2 : unsigned(17 downto 0) := to_unsigned(home_2, 18);
--    signal reg_3 : unsigned(17 downto 0) := to_unsigned(home_3, 18);
--    signal reg_4 : unsigned(17 downto 0) := to_unsigned(home_4, 18);
--    signal reg_5 : unsigned(17 downto 0) := to_unsigned(home_5, 18);
--begin

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                -- Reset to HOME (1.5ms pulse), not zero!
--                reg_0 <= to_unsigned(home_0, 18);
--                reg_1 <= to_unsigned(home_1, 18);
--                reg_2 <= to_unsigned(home_2, 18);
--                reg_3 <= to_unsigned(home_3, 18);
--                reg_4 <= to_unsigned(home_4, 18);
--                reg_5 <= to_unsigned(home_5, 18);
--            elsif wr_en = '1' then
--                case sel is
--                    when "000" => reg_0 <= wr_data;
--                    when "001" => reg_1 <= wr_data;
--                    when "010" => reg_2 <= wr_data;
--                    when "011" => reg_3 <= wr_data;
--                    when "100" => reg_4 <= wr_data;
--                    when "101" => reg_5 <= wr_data;
--                    when others => null;
--                end case;
--            end if;
--        end if;
--    end process;

--    cmd_0 <= reg_0;
--    cmd_1 <= reg_1;
--    cmd_2 <= reg_2;
--    cmd_3 <= reg_3;
--    cmd_4 <= reg_4;
--    cmd_5 <= reg_5;

--end Behavioral;


-- ===================================================================
-- ACTIVE: button-mapping demo
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity joint_regfile is
    generic (
        -- home pose values for each joint (must match control_fsm home values)
        home_0 : integer := 150000;
        home_1 : integer := 150000;
        home_2 : integer := 150000;
        home_3 : integer := 150000;
        home_4 : integer := 150000;
        home_5 : integer := 150000   -- gripper centered (was 100000)
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sel : in unsigned(2 downto 0);
           wr_en : in STD_LOGIC;
           wr_data : in unsigned(17 downto 0);
           cmd_0 : out unsigned(17 downto 0);
           cmd_1 : out unsigned(17 downto 0);
           cmd_2 : out unsigned(17 downto 0);
           cmd_3 : out unsigned(17 downto 0);
           cmd_4 : out unsigned(17 downto 0);
           cmd_5 : out unsigned(17 downto 0));
end joint_regfile;

architecture Behavioral of joint_regfile is
    signal reg_0 : unsigned(17 downto 0) := to_unsigned(home_0, 18);
    signal reg_1 : unsigned(17 downto 0) := to_unsigned(home_1, 18);
    signal reg_2 : unsigned(17 downto 0) := to_unsigned(home_2, 18);
    signal reg_3 : unsigned(17 downto 0) := to_unsigned(home_3, 18);
    signal reg_4 : unsigned(17 downto 0) := to_unsigned(home_4, 18);
    signal reg_5 : unsigned(17 downto 0) := to_unsigned(home_5, 18);
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Reset to HOME (1.5ms pulse), not zero!
                reg_0 <= to_unsigned(home_0, 18);
                reg_1 <= to_unsigned(home_1, 18);
                reg_2 <= to_unsigned(home_2, 18);
                reg_3 <= to_unsigned(home_3, 18);
                reg_4 <= to_unsigned(home_4, 18);
                reg_5 <= to_unsigned(home_5, 18);
            elsif wr_en = '1' then
                case sel is
                    when "000" => reg_0 <= wr_data;
                    when "001" => reg_1 <= wr_data;
                    when "010" => reg_2 <= wr_data;
                    when "011" => reg_3 <= wr_data;
                    when "100" => reg_4 <= wr_data;
                    when "101" => reg_5 <= wr_data;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    cmd_0 <= reg_0;
    cmd_1 <= reg_1;
    cmd_2 <= reg_2;
    cmd_3 <= reg_3;
    cmd_4 <= reg_4;
    cmd_5 <= reg_5;

end Behavioral;
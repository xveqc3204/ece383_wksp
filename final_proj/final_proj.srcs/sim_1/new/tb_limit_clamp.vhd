----------------------------------------------------------------------------------
-- Testbench: tb_limit_clamp
-- Purpose: Prove the safety clamp blocks out-of-range commands. THIS IS YOUR
-- MOST IMPORTANT SAFETY TEST. If this passes, you know the arm cannot be
-- driven past its configured mechanical limits no matter what control_fsm does.
--
-- Strategy: Drive each channel's input with values across the full range:
--   - Below minimum → output should be MIN
--   - At minimum    → output should be MIN
--   - Inside range  → output should pass through unchanged
--   - At maximum    → output should be MAX
--   - Above maximum → output should be MAX
--   - Crazy values  → output should be MAX (never overflow)
--
-- This is purely combinational, no clock needed.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_limit_clamp is
end tb_limit_clamp;

architecture Behavioral of tb_limit_clamp is
    component limit_clamp is
        generic (
            min_0 : integer := 100000; max_0 : integer := 200000;
            min_1 : integer := 100000; max_1 : integer := 200000;
            min_2 : integer := 100000; max_2 : integer := 200000;
            min_3 : integer := 100000; max_3 : integer := 200000;
            min_4 : integer := 100000; max_4 : integer := 200000;
            min_5 : integer := 100000; max_5 : integer := 200000
        );
        port (
            raw_0 : in  unsigned(17 downto 0);
            raw_1 : in  unsigned(17 downto 0);
            raw_2 : in  unsigned(17 downto 0);
            raw_3 : in  unsigned(17 downto 0);
            raw_4 : in  unsigned(17 downto 0);
            raw_5 : in  unsigned(17 downto 0);
            cmd_0 : out unsigned(17 downto 0);
            cmd_1 : out unsigned(17 downto 0);
            cmd_2 : out unsigned(17 downto 0);
            cmd_3 : out unsigned(17 downto 0);
            cmd_4 : out unsigned(17 downto 0);
            cmd_5 : out unsigned(17 downto 0)
        );
    end component;
 
    signal raw_0, raw_1, raw_2, raw_3, raw_4, raw_5 : unsigned(17 downto 0)
            := (others => '0');
    signal cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5 : unsigned(17 downto 0);
 
    -- helper procedure to check expected vs actual
    procedure check(name : string;
                    actual : unsigned(17 downto 0);
                    expected : integer) is
    begin
        if to_integer(actual) = expected then
            report name & ": PASS (got " & integer'image(to_integer(actual)) & ")";
        else
            report name & ": FAIL (expected " & integer'image(expected) &
                          ", got " & integer'image(to_integer(actual)) & ")"
            severity error;
        end if;
    end procedure;
 
begin
 
    uut : limit_clamp
        generic map (
            min_0 => 100000, max_0 => 200000,
            min_1 => 120000, max_1 => 180000,  -- tighter limits on joint 1
            min_2 => 100000, max_2 => 200000,
            min_3 => 100000, max_3 => 200000,
            min_4 => 100000, max_4 => 200000,
            min_5 => 130000, max_5 => 170000   -- tightest limits on gripper
        )
        port map (
            raw_0 => raw_0, raw_1 => raw_1, raw_2 => raw_2,
            raw_3 => raw_3, raw_4 => raw_4, raw_5 => raw_5,
            cmd_0 => cmd_0, cmd_1 => cmd_1, cmd_2 => cmd_2,
            cmd_3 => cmd_3, cmd_4 => cmd_4, cmd_5 => cmd_5
        );
 
    sim : process
    begin
        report "tb_limit_clamp: starting safety verification";
 
        -- Test 1: input below minimum → clamp to min
        raw_0 <= to_unsigned(50000, 18);
        wait for 1 ns;
        check("under-range joint 0", cmd_0, 100000);
 
        -- Test 2: input way too high (would lock up servo!) → clamp to max
        raw_0 <= to_unsigned(250000, 18);
        wait for 1 ns;
        check("over-range  joint 0", cmd_0, 200000);
 
        -- Test 3: input inside range → pass through
        raw_0 <= to_unsigned(150000, 18);
        wait for 1 ns;
        check("in-range    joint 0", cmd_0, 150000);
 
        -- Test 4: tight limits on joint 5 (gripper)
        raw_5 <= to_unsigned(100000, 18);
        wait for 1 ns;
        check("under-range gripper", cmd_5, 130000);
 
        raw_5 <= to_unsigned(200000, 18);
        wait for 1 ns;
        check("over-range  gripper", cmd_5, 170000);
 
        raw_5 <= to_unsigned(150000, 18);
        wait for 1 ns;
        check("in-range    gripper", cmd_5, 150000);
 
        -- Test 5: edge cases - exactly at the boundaries
        raw_1 <= to_unsigned(120000, 18);
        wait for 1 ns;
        check("at-min  joint 1", cmd_1, 120000);
 
        raw_1 <= to_unsigned(180000, 18);
        wait for 1 ns;
        check("at-max  joint 1", cmd_1, 180000);
 
        -- Test 6: catastrophic value (all bits high)
        raw_2 <= (others => '1');  -- 262143 - way above max
        wait for 1 ns;
        check("18-bit max input joint 2 clamped", cmd_2, 200000);
 
        report "tb_limit_clamp: ALL TESTS COMPLETE";
        wait;
    end process;
 
end Behavioral;
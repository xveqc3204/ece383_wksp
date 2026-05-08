----------------------------------------------------------------------------------
-- Module Name: limit_clamp - Behavioral
-- Description: Combinational saturation block. Clamps each raw joint command
--              to its per-joint min/max bound so the FSM cannot ever drive
--              the arm past its mechanical limits, regardless of input.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity limit_clamp is
    generic (
           -- tune these after calibrating the arm
           min_0 : integer := 100000;
           max_0 : integer := 200000;  -- base
           min_1 : integer := 100000;
           max_1 : integer := 200000;  -- shoulder
           min_2 : integer := 100000;
           max_2 : integer := 200000;  -- elbow
           min_3 : integer := 100000;
           max_3 : integer := 200000;  -- wrist pitch
           min_4 : integer := 100000;
           max_4 : integer := 200000;  -- wrist rotate
           min_5 : integer := 100000;
           max_5 : integer := 200000   -- gripper
    );
    port ( raw_0 : in unsigned(17 downto 0);
           raw_1 : in unsigned(17 downto 0);
           raw_2 : in unsigned(17 downto 0);
           raw_3 : in unsigned(17 downto 0);
           raw_4 : in unsigned(17 downto 0);
           raw_5 : in unsigned(17 downto 0);
           cmd_0 : out unsigned(17 downto 0);
           cmd_1 : out unsigned(17 downto 0);
           cmd_2 : out unsigned(17 downto 0);
           cmd_3 : out unsigned(17 downto 0);
           cmd_4 : out unsigned(17 downto 0);
           cmd_5 : out unsigned(17 downto 0));
end limit_clamp;

architecture Behavioral of limit_clamp is
begin

    cmd_0 <= to_unsigned(min_0, 18) when raw_0 < to_unsigned(min_0, 18) else
             to_unsigned(max_0, 18) when raw_0 > to_unsigned(max_0, 18) else
             raw_0;

    cmd_1 <= to_unsigned(min_1, 18) when raw_1 < to_unsigned(min_1, 18) else
             to_unsigned(max_1, 18) when raw_1 > to_unsigned(max_1, 18) else
             raw_1;

    cmd_2 <= to_unsigned(min_2, 18) when raw_2 < to_unsigned(min_2, 18) else
             to_unsigned(max_2, 18) when raw_2 > to_unsigned(max_2, 18) else
             raw_2;

    cmd_3 <= to_unsigned(min_3, 18) when raw_3 < to_unsigned(min_3, 18) else
             to_unsigned(max_3, 18) when raw_3 > to_unsigned(max_3, 18) else
             raw_3;

    cmd_4 <= to_unsigned(min_4, 18) when raw_4 < to_unsigned(min_4, 18) else
             to_unsigned(max_4, 18) when raw_4 > to_unsigned(max_4, 18) else
             raw_4;

    cmd_5 <= to_unsigned(min_5, 18) when raw_5 < to_unsigned(min_5, 18) else
             to_unsigned(max_5, 18) when raw_5 > to_unsigned(max_5, 18) else
             raw_5;

end Behavioral;
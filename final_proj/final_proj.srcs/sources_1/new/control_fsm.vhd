----------------------------------------------------------------------------------
-- Module Name: control_fsm - Behavioral
-- Description: User-facing FSM that decodes button state and issues writes
--              to the joint register file.  Standard NES bit map (after the
--              postLatchWait fix in nes_interface):
--
--                bit 0 = Right     bit 4 = Start
--                bit 1 = Left      bit 5 = Select
--                bit 2 = Down      bit 6 = B
--                bit 3 = Up        bit 7 = A
--
-- Up / Down cycle the selected joint.  Right / Left increment / decrement the
-- current joint command using bounded add/sub so the regfile cannot under- or
-- overflow.  A / B drive the gripper.  Start snaps to home.  A cooldown
-- counter gates how often a single press can fire so one button press is not
-- interpreted as many.
--
-- This file contains TWO iterations.  Only one is active at a time.
--
--   ACTIVE (below):    Standard NES bit map, used for the button-mapping demo.
--                      Pairs with the fixed nes_interface that captures bit 7
--                      correctly.
--
--   COMMENTED OUT:     Earlier iteration with shifted bit positions.  This
--                      version was used while debugging the nes_interface
--                      timing bug (bit 7 was being missed, so the FSM expected
--                      remapped bits).  Kept as a debugging fallback.
----------------------------------------------------------------------------------


-- ===================================================================
-- ALTERNATE: earlier iteration with shifted bit positions (commented out)
-- ===================================================================

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity control_fsm is
--    generic (
--           tick_cycles : integer := 1600000;
--           step_med_ticks : integer := 15;
--           step_fast_ticks : integer := 60;
--           step_slow : integer := 100;
--           step_med : integer := 500;
--           step_fast : integer := 2000;
--           home_0 : integer := 150000;
--           home_1 : integer := 150000;
--           home_2 : integer := 150000;
--           home_3 : integer := 150000;
--           home_4 : integer := 150000;
--           home_5 : integer := 150000;
--           cmd_min : integer := 100000;
--           cmd_max : integer := 200000;
--           cooldown_ticks : integer := 8
--    );
--    port ( clk : in STD_LOGIC;
--           reset_n : in STD_LOGIC;
--           buttons : in std_logic_vector(7 downto 0);
--           cmd_0 : in unsigned(17 downto 0);
--           cmd_1 : in unsigned(17 downto 0);
--           cmd_2 : in unsigned(17 downto 0);
--           cmd_3 : in unsigned(17 downto 0);
--           cmd_4 : in unsigned(17 downto 0);
--           cmd_5 : in unsigned(17 downto 0);
--           sel : out unsigned(2 downto 0);
--           wr_en : out STD_LOGIC;
--           wr_data : out unsigned(17 downto 0);
--           selected_led : out unsigned(2 downto 0));
--end control_fsm;

--architecture Behavioral of control_fsm is
--    type state_t is (idle, movePos, moveNeg, gripOpen, gripClose, resetHome);
--    signal state : state_t := idle;

--    signal tick_cnt : unsigned(20 downto 0) := (others => '0');
--    signal tick : std_logic := '0';

--    signal selected : unsigned(2 downto 0) := (others => '0');
--    signal hold_cnt : unsigned(7 downto 0) := (others => '0');
--    signal home_idx : unsigned(2 downto 0) := (others => '0');
--    signal cooldown : unsigned(4 downto 0) := (others => '0');

--    signal i_sel : unsigned(2 downto 0) := (others => '0');
--    signal i_wr_en : std_logic := '0';
--    signal i_wr_data : unsigned(17 downto 0) := (others => '0');

--    constant CMD_MIN_U : unsigned(17 downto 0) := to_unsigned(cmd_min, 18);
--    constant CMD_MAX_U : unsigned(17 downto 0) := to_unsigned(cmd_max, 18);

--    -- ====== STANDARD NES BIT MAP ======
--    constant BIT_RIGHT  : integer := 0;
--    constant BIT_LEFT   : integer := 1;
--    constant BIT_DOWN   : integer := 2;
--    constant BIT_UP     : integer := 3;
--    constant BIT_START  : integer := 4;
--    constant BIT_SELECT : integer := 5;
--    constant BIT_B      : integer := 6;
--    constant BIT_A      : integer := 7;
--    -- ===================================

--    function pick_cmd (sel : unsigned(2 downto 0);
--                       c0, c1, c2, c3, c4, c5 : unsigned(17 downto 0))
--                       return unsigned is
--    begin
--        case sel is
--            when "000" => return c0;
--            when "001" => return c1;
--            when "010" => return c2;
--            when "011" => return c3;
--            when "100" => return c4;
--            when others => return c5;
--        end case;
--    end function;

--    function pick_home (idx : unsigned(2 downto 0)) return unsigned is
--    begin
--        case idx is
--            when "000" => return to_unsigned(home_0, 18);
--            when "001" => return to_unsigned(home_1, 18);
--            when "010" => return to_unsigned(home_2, 18);
--            when "011" => return to_unsigned(home_3, 18);
--            when "100" => return to_unsigned(home_4, 18);
--            when others => return to_unsigned(home_5, 18);
--        end case;
--    end function;

--    function pick_step (h : unsigned(7 downto 0)) return unsigned is
--    begin
--        if h < to_unsigned(step_med_ticks, 8) then
--            return to_unsigned(step_slow, 18);
--        elsif h < to_unsigned(step_fast_ticks, 8) then
--            return to_unsigned(step_med, 18);
--        else
--            return to_unsigned(step_fast, 18);
--        end if;
--    end function;

--    function bounded_add (a, b : unsigned(17 downto 0)) return unsigned is
--        variable sum : unsigned(18 downto 0);
--    begin
--        sum := ('0' & a) + ('0' & b);
--        if sum >= ('0' & CMD_MAX_U) then
--            return CMD_MAX_U;
--        else
--            return sum(17 downto 0);
--        end if;
--    end function;

--    function bounded_sub (a, b : unsigned(17 downto 0)) return unsigned is
--    begin
--        if a <= CMD_MIN_U + b then
--            return CMD_MIN_U;
--        else
--            return a - b;
--        end if;
--    end function;

--begin

--    tick_process : process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                tick_cnt <= (others => '0');
--                tick <= '0';
--            elsif tick_cnt = to_unsigned(tick_cycles - 1, tick_cnt'length) then
--                tick_cnt <= (others => '0');
--                tick <= '1';
--            else
--                tick_cnt <= tick_cnt + 1;
--                tick <= '0';
--            end if;
--        end if;
--    end process;

--    state_process : process(clk)
--        variable cur_val : unsigned(17 downto 0);
--        variable step    : unsigned(17 downto 0);
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                state <= idle;
--                selected <= (others => '0');
--                hold_cnt <= (others => '0');
--                home_idx <= (others => '0');
--                cooldown <= (others => '0');
--                i_sel <= (others => '0');
--                i_wr_en <= '0';
--                i_wr_data <= (others => '0');
--            else
--                i_wr_en <= '0';

--                if tick = '1' then
--                    if cooldown > 0 then
--                        cooldown <= cooldown - 1;
--                    end if;

--                    case state is
--                        when idle =>
--                            hold_cnt <= (others => '0');

--                            if cooldown = 0 then
--                                if buttons(BIT_UP) = '1' then
--                                    if selected = to_unsigned(5, 3) then
--                                        selected <= (others => '0');
--                                    else
--                                        selected <= selected + 1;
--                                    end if;
--                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
--                                elsif buttons(BIT_DOWN) = '1' then
--                                    if selected = to_unsigned(0, 3) then
--                                        selected <= to_unsigned(5, 3);
--                                    else
--                                        selected <= selected - 1;
--                                    end if;
--                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
--                                elsif buttons(BIT_START) = '1' then
--                                    state <= resetHome;
--                                    home_idx <= (others => '0');
--                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
--                                end if;
--                            end if;

--                            if buttons(BIT_RIGHT) = '1' then
--                                state <= movePos;
--                            elsif buttons(BIT_LEFT) = '1' then
--                                state <= moveNeg;
--                            elsif buttons(BIT_A) = '1' then
--                                state <= gripOpen;
--                            elsif buttons(BIT_B) = '1' then
--                                state <= gripClose;
--                            end if;

--                        when movePos =>
--                            cur_val := pick_cmd(selected, cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5);
--                            step := pick_step(hold_cnt);
--                            i_sel <= selected;
--                            i_wr_en <= '1';
--                            i_wr_data <= bounded_add(cur_val, step);
--                            if buttons(BIT_RIGHT) = '1' then
--                                hold_cnt <= hold_cnt + 1;
--                            else
--                                state <= idle;
--                            end if;

--                        when moveNeg =>
--                            cur_val := pick_cmd(selected, cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5);
--                            step := pick_step(hold_cnt);
--                            i_sel <= selected;
--                            i_wr_en <= '1';
--                            i_wr_data <= bounded_sub(cur_val, step);
--                            if buttons(BIT_LEFT) = '1' then
--                                hold_cnt <= hold_cnt + 1;
--                            else
--                                state <= idle;
--                            end if;

--                        when gripOpen =>
--                            cur_val := cmd_5;
--                            step := pick_step(hold_cnt);
--                            i_sel <= to_unsigned(5, 3);
--                            i_wr_en <= '1';
--                            i_wr_data <= bounded_add(cur_val, step);
--                            if buttons(BIT_A) = '1' then
--                                hold_cnt <= hold_cnt + 1;
--                            else
--                                state <= idle;
--                            end if;

--                        when gripClose =>
--                            cur_val := cmd_5;
--                            step := pick_step(hold_cnt);
--                            i_sel <= to_unsigned(5, 3);
--                            i_wr_en <= '1';
--                            i_wr_data <= bounded_sub(cur_val, step);
--                            if buttons(BIT_B) = '1' then
--                                hold_cnt <= hold_cnt + 1;
--                            else
--                                state <= idle;
--                            end if;

--                        when resetHome =>
--                            i_sel <= home_idx;
--                            i_wr_en <= '1';
--                            i_wr_data <= pick_home(home_idx);
--                            if home_idx = to_unsigned(5, 3) then
--                                state <= idle;
--                            else
--                                home_idx <= home_idx + 1;
--                            end if;
--                    end case;
--                end if;
--            end if;
--        end if;
--    end process;

--    sel <= i_sel;
--    wr_en <= i_wr_en;
--    wr_data <= i_wr_data;
--    selected_led <= selected;

--end Behavioral;


-- ===================================================================
-- ACTIVE: button-mapping demo
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity control_fsm is
    generic (
           tick_cycles : integer := 1600000;
           step_med_ticks : integer := 15;
           step_fast_ticks : integer := 60;
           step_slow : integer := 100;
           step_med : integer := 500;
           step_fast : integer := 2000;
           home_0 : integer := 150000;
           home_1 : integer := 150000;
           home_2 : integer := 150000;
           home_3 : integer := 150000;
           home_4 : integer := 150000;
           home_5 : integer := 150000;
           cmd_min : integer := 100000;
           cmd_max : integer := 200000;
           cooldown_ticks : integer := 8
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           buttons : in std_logic_vector(7 downto 0);
           cmd_0 : in unsigned(17 downto 0);
           cmd_1 : in unsigned(17 downto 0);
           cmd_2 : in unsigned(17 downto 0);
           cmd_3 : in unsigned(17 downto 0);
           cmd_4 : in unsigned(17 downto 0);
           cmd_5 : in unsigned(17 downto 0);
           sel : out unsigned(2 downto 0);
           wr_en : out STD_LOGIC;
           wr_data : out unsigned(17 downto 0);
           selected_led : out unsigned(2 downto 0));
end control_fsm;

architecture Behavioral of control_fsm is
    type state_t is (idle, movePos, moveNeg, gripOpen, gripClose, resetHome);
    signal state : state_t := idle;

    signal tick_cnt : unsigned(20 downto 0) := (others => '0');
    signal tick : std_logic := '0';

    signal selected : unsigned(2 downto 0) := (others => '0');
    signal hold_cnt : unsigned(7 downto 0) := (others => '0');
    signal home_idx : unsigned(2 downto 0) := (others => '0');
    signal cooldown : unsigned(4 downto 0) := (others => '0');

    signal i_sel : unsigned(2 downto 0) := (others => '0');
    signal i_wr_en : std_logic := '0';
    signal i_wr_data : unsigned(17 downto 0) := (others => '0');

    constant CMD_MIN_U : unsigned(17 downto 0) := to_unsigned(cmd_min, 18);
    constant CMD_MAX_U : unsigned(17 downto 0) := to_unsigned(cmd_max, 18);

    -- ====== STANDARD NES BIT MAP ======
    constant BIT_RIGHT  : integer := 0;
    constant BIT_LEFT   : integer := 1;
    constant BIT_DOWN   : integer := 2;
    constant BIT_UP     : integer := 3;
    constant BIT_START  : integer := 4;
    constant BIT_SELECT : integer := 5;
    constant BIT_B      : integer := 6;
    constant BIT_A      : integer := 7;
    -- ===================================

    function pick_cmd (sel : unsigned(2 downto 0);
                       c0, c1, c2, c3, c4, c5 : unsigned(17 downto 0))
                       return unsigned is
    begin
        case sel is
            when "000" => return c0;
            when "001" => return c1;
            when "010" => return c2;
            when "011" => return c3;
            when "100" => return c4;
            when others => return c5;
        end case;
    end function;

    function pick_home (idx : unsigned(2 downto 0)) return unsigned is
    begin
        case idx is
            when "000" => return to_unsigned(home_0, 18);
            when "001" => return to_unsigned(home_1, 18);
            when "010" => return to_unsigned(home_2, 18);
            when "011" => return to_unsigned(home_3, 18);
            when "100" => return to_unsigned(home_4, 18);
            when others => return to_unsigned(home_5, 18);
        end case;
    end function;

    function pick_step (h : unsigned(7 downto 0)) return unsigned is
    begin
        if h < to_unsigned(step_med_ticks, 8) then
            return to_unsigned(step_slow, 18);
        elsif h < to_unsigned(step_fast_ticks, 8) then
            return to_unsigned(step_med, 18);
        else
            return to_unsigned(step_fast, 18);
        end if;
    end function;

    function bounded_add (a, b : unsigned(17 downto 0)) return unsigned is
        variable sum : unsigned(18 downto 0);
    begin
        sum := ('0' & a) + ('0' & b);
        if sum >= ('0' & CMD_MAX_U) then
            return CMD_MAX_U;
        else
            return sum(17 downto 0);
        end if;
    end function;

    function bounded_sub (a, b : unsigned(17 downto 0)) return unsigned is
    begin
        if a <= CMD_MIN_U + b then
            return CMD_MIN_U;
        else
            return a - b;
        end if;
    end function;

begin

    tick_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                tick_cnt <= (others => '0');
                tick <= '0';
            elsif tick_cnt = to_unsigned(tick_cycles - 1, tick_cnt'length) then
                tick_cnt <= (others => '0');
                tick <= '1';
            else
                tick_cnt <= tick_cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    state_process : process(clk)
        variable cur_val : unsigned(17 downto 0);
        variable step    : unsigned(17 downto 0);
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= idle;
                selected <= (others => '0');
                hold_cnt <= (others => '0');
                home_idx <= (others => '0');
                cooldown <= (others => '0');
                i_sel <= (others => '0');
                i_wr_en <= '0';
                i_wr_data <= (others => '0');
            else
                i_wr_en <= '0';

                if tick = '1' then
                    if cooldown > 0 then
                        cooldown <= cooldown - 1;
                    end if;

                    case state is
                        when idle =>
                            hold_cnt <= (others => '0');

                            if cooldown = 0 then
                                if buttons(BIT_UP) = '1' then
                                    if selected = to_unsigned(5, 3) then
                                        selected <= (others => '0');
                                    else
                                        selected <= selected + 1;
                                    end if;
                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
                                elsif buttons(BIT_DOWN) = '1' then
                                    if selected = to_unsigned(0, 3) then
                                        selected <= to_unsigned(5, 3);
                                    else
                                        selected <= selected - 1;
                                    end if;
                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
                                elsif buttons(BIT_START) = '1' then
                                    state <= resetHome;
                                    home_idx <= (others => '0');
                                    cooldown <= to_unsigned(cooldown_ticks, cooldown'length);
                                end if;
                            end if;

                            if buttons(BIT_RIGHT) = '1' then
                                state <= movePos;
                            elsif buttons(BIT_LEFT) = '1' then
                                state <= moveNeg;
                            elsif buttons(BIT_A) = '1' then
                                state <= gripOpen;
                            elsif buttons(BIT_B) = '1' then
                                state <= gripClose;
                            end if;

                        when movePos =>
                            cur_val := pick_cmd(selected, cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5);
                            step := pick_step(hold_cnt);
                            i_sel <= selected;
                            i_wr_en <= '1';
                            i_wr_data <= bounded_add(cur_val, step);
                            if buttons(BIT_RIGHT) = '1' then
                                hold_cnt <= hold_cnt + 1;
                            else
                                state <= idle;
                            end if;

                        when moveNeg =>
                            cur_val := pick_cmd(selected, cmd_0, cmd_1, cmd_2, cmd_3, cmd_4, cmd_5);
                            step := pick_step(hold_cnt);
                            i_sel <= selected;
                            i_wr_en <= '1';
                            i_wr_data <= bounded_sub(cur_val, step);
                            if buttons(BIT_LEFT) = '1' then
                                hold_cnt <= hold_cnt + 1;
                            else
                                state <= idle;
                            end if;

                        when gripOpen =>
                            cur_val := cmd_5;
                            step := pick_step(hold_cnt);
                            i_sel <= to_unsigned(5, 3);
                            i_wr_en <= '1';
                            i_wr_data <= bounded_add(cur_val, step);
                            if buttons(BIT_A) = '1' then
                                hold_cnt <= hold_cnt + 1;
                            else
                                state <= idle;
                            end if;

                        when gripClose =>
                            cur_val := cmd_5;
                            step := pick_step(hold_cnt);
                            i_sel <= to_unsigned(5, 3);
                            i_wr_en <= '1';
                            i_wr_data <= bounded_sub(cur_val, step);
                            if buttons(BIT_B) = '1' then
                                hold_cnt <= hold_cnt + 1;
                            else
                                state <= idle;
                            end if;

                        when resetHome =>
                            i_sel <= home_idx;
                            i_wr_en <= '1';
                            i_wr_data <= pick_home(home_idx);
                            if home_idx = to_unsigned(5, 3) then
                                state <= idle;
                            else
                                home_idx <= home_idx + 1;
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end process;

    sel <= i_sel;
    wr_en <= i_wr_en;
    wr_data <= i_wr_data;
    selected_led <= selected;

end Behavioral;
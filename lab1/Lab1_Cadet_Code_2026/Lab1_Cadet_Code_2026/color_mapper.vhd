----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( color : out color_t;
           position: in coordinate_t;
		   trigger : in trigger_t;
           ch1 : in channel_t;
           ch2 : in channel_t);
end color_mapper;

architecture color_mapper_arch of color_mapper is

signal trigger_color : color_t := YELLOW; 
signal ch1_color : color_t := YELLOW; 
signal ch2_color : color_t := GREEN; 
signal grid_color : color_t := WHITE; 
signal background_color : color_t := BLACK; 
signal hash_color : color_t := WHITE; 
-- Add other colors you want to use here

signal is_vertical_gridline, is_horizontal_gridline, is_within_grid, is_trigger_time, is_trigger_volt, is_ch1_line, is_ch2_line,
    is_horizontal_hash, is_vertical_hash, is_within_trigger_v_range, is_within_trigger_t_range : boolean := false;

-- Fill in values here
constant grid_start_row : integer := 20;
constant grid_stop_row : integer := 420;
constant grid_start_col : integer := 20;
constant grid_stop_col : integer := 620;
constant num_horizontal_gridblocks : integer := 10;
constant num_vertical_gridblocks : integer := 8;
constant center_column : integer := 320;
constant center_row : integer := 220;
constant hash_size : integer := 9;
constant hash_horizontal_spacing : integer := 15;
constant hash_vertical_spacing : integer := 10;
constant trigger_width : integer := 20;  
constant trigger_height : integer := 10;  

begin

-- Gridlines: use modulo to drop a line every N pixels inside the grid area
-- (spacing = grid size / number of blocks)
is_vertical_gridline <= true when (
    (((to_integer(position.col) - grid_start_col) mod
    ((grid_stop_col-grid_start_col)/num_horizontal_gridblocks)) = 0)
    and is_within_grid
) else false;

is_horizontal_gridline <= true when (
    (((to_integer(position.row) - grid_start_row) mod
    ((grid_stop_row-grid_start_row)/num_vertical_gridblocks)) = 0)
    and is_within_grid
) else false;


is_within_grid <= true when ((position.row <= grid_stop_row)   and 
                             (position.row >= grid_start_row)  and
                             (position.col <= grid_stop_col)   and 
                             (position.col >= grid_start_col)) else false;
                             
is_ch1_line <= true when ((ch1.active = '1') and (ch1.en = '1') and is_within_grid) else false;
is_ch2_line <= true when ((ch2.active = '1') and (ch2.en = '1') and is_within_grid) else false;

--Documentation: C2C Metwally helped me thoroughly understand his process in discussion as I found it to be
--much more simple than how I originally approached drawing the hashes and trigger below.

is_horizontal_hash <= true when (
    (not is_vertical_gridline) and is_within_grid and
    (((to_integer(position.col) - grid_start_col) mod hash_horizontal_spacing) = 0) and
    ((to_integer(position.row) <= center_row + hash_size/2) and
    (to_integer(position.row) >= center_row - hash_size/2))
) else false;

is_vertical_hash <= true when (
    (not is_horizontal_gridline) and is_within_grid and
    (((to_integer(position.row) - grid_start_row) mod hash_vertical_spacing) = 0) and
    ((to_integer(position.col) <= center_column + hash_size/2) and
    (to_integer(position.col) >= center_column - hash_size/2))
) else false;

-- Trigger guard rails: limit trigger markers to the top/left bands around the grid
-- so we dont draw trigger triangles all over the screen
is_within_trigger_t_range <= (position.row >= grid_start_row) and (position.row <= grid_start_row + trigger_height)
and (position.col >= grid_start_col - trigger_width / 2) and (position.col <= grid_stop_col + trigger_width / 2);

is_within_trigger_v_range <= (position.row >= grid_start_row - trigger_width / 2) and (position.row <= grid_stop_row + trigger_width / 2)
and (position.col >= grid_start_col) and (position.col <= grid_start_col + trigger_height);
   
-- The abs() math creates the triangle slope from the center point                              
is_trigger_time <= (abs(to_integer(position.col) - to_integer(trigger.t))) <= (trigger_width / 2) and
(trigger_width / 2 - (abs(to_integer(position.col) - to_integer(trigger.t)))) >= abs(to_integer(position.row) - grid_start_row)
and is_within_trigger_t_range;

is_trigger_volt <= (abs(to_integer(position.row) - to_integer(trigger.v))) <= (trigger_width / 2) and
(trigger_width / 2 - abs(to_integer(position.row) - to_integer(trigger.v))) >= abs(to_integer(position.col) - grid_start_col)
and is_within_trigger_v_range;



----Copy of previous iteration of triggers to to test on the website, force draw at center, works
--is_trigger_time <= true when (
--    (position.col >= grid_start_col) and (position.col <= grid_stop_col) and
--    (position.row >= grid_start_row - trigger_height) and (position.row < grid_start_row) and
--    (abs(to_integer(position.col) - center_column) <=
--     (grid_start_row - 1 - to_integer(position.row)))
--) else false;

--is_trigger_volt <= true when (
--    (position.row >= grid_start_row) and (position.row <= grid_stop_row) and
--    (position.col >= grid_start_col - trigger_height) and (position.col < grid_start_col) and
--    (abs(to_integer(position.row) - center_row) <=
--     (grid_start_col - 1 - to_integer(position.col)))
--) else false;


-- Use your booleans to choose the color
color <= trigger_color when (is_trigger_time or is_trigger_volt) else
         ch1_color   when is_ch1_line else
         ch2_color   when is_ch2_line else
         grid_color  when (is_vertical_gridline or is_horizontal_gridline) else
         hash_color  when (is_horizontal_hash or is_vertical_hash) else
         background_color;   
                                   
end color_mapper_arch;

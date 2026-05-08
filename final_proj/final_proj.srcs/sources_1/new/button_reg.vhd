----------------------------------------------------------------------------------
-- Module Name: button_reg - Behavioral
-- Description: One-clock register that holds the latched NES button word.
--              Acts as a synchronizer between the nes_interface output and
--              the rest of the FPGA logic.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity button_reg is
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           d : in std_logic_vector(7 downto 0);
           q : out std_logic_vector(7 downto 0));
end button_reg;

architecture Behavioral of button_reg is
    signal reg : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                reg <= (others => '0');
            else
                reg <= d;
            end if;
        end if;
    end process;

    q <= reg;

end Behavioral;
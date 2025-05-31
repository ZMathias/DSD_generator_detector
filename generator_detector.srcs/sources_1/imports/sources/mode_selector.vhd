library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- vetted and works

entity mode_selector is
port(
    CLK: in std_logic;
    MD0, MD1, MD2, MD3: in std_logic;
    MODE: in std_logic_vector(1 downto 0);
    Qnext: in std_logic;
    FC: in std_logic;
    OUT_EN: in std_logic;
    Di: out std_logic
);
end entity mode_selector;

architecture behavioural of mode_selector is
begin

process(CLK, MODE, FC, Qnext)
variable sel: std_logic_vector(3 downto 0) := (others => '0');
begin
    
    if rising_edge(CLK) then
        sel(3) := FC;
        sel(2) := OUT_EN;
        sel(1) := MODE(1);
        sel(0) := MODE(0);
        
        case sel is
            when x"0" => Di <= MD0;
            when x"1" => Di <= MD1;
            when x"2" => Di <= MD2;
            when x"3" => Di <= MD3;
            when x"4" => Di <= Qnext;
            when x"5" => Di <= Qnext;
            when x"6" => Di <= Qnext;
            when x"7" => Di <= Qnext;
            when x"8" => Di <= MD0;
            when x"9" => Di <= MD0;
            when x"A" => Di <= MD0;
            when x"B" => Di <= MD0;
            when x"C" => Di <= Qnext;
            when x"D" => Di <= Qnext;
            when x"E" => Di <= Qnext;
            when x"F" => Di <= Qnext;
        end case;
   end if; 
end process;

end architecture behavioural;
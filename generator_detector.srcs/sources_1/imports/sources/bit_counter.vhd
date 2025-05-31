library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bit_counter is
port(
    clk, cnt_en: in std_logic;
    T_END: out std_logic
);
end bit_counter;

architecture behavioural of bit_counter is
begin

process(clk, cnt_en)

variable counter: unsigned(4 downto 0) := (others => '0');

begin
    
    if cnt_en = '0' then
        counter := (others => '0');
    elsif cnt_en = '1' then
        if rising_edge(clk) then
            counter := counter + 1; -- increment counter at each front
            if counter = 26 then -- we count 27 states
                T_END <= '1';
            else T_END <= '0';         
            end if;
        end if;
    end if;

end process;

end architecture behavioural;
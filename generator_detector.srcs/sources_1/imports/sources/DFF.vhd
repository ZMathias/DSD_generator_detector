library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF is
    port(d, reset, clk : in std_logic;
        q : out std_logic);
end DFF;

architecture Behavioral of DFF is

begin
-- Clocked Delay flip-flop process
process(clk, reset)

begin
    if reset = '1' then
        q <= '0'; -- reset is asynchronos
    elsif clk'event and clk = '1'  then
        q <= d; --clocked asignation of value to internal state
    end if;      
end process;
end Behavioral;

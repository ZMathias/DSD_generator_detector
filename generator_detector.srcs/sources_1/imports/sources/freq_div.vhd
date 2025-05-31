library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity freq_div is
    port(
        clk100: in std_logic;
        clk_1hz: out std_logic
    );
end freq_div;

-- describes a single frequency divider that divides the 100mhz clock by 2^26. This equates to a period of roughly ~1.3 seconds
architecture behavioural of freq_div is

signal n: std_logic_vector(26 downto 0) := (others => '0');

begin
    process(clk100, n)
    begin
        if clk100'event and clk100='1' then
            n <= n + 1;
        end if;
        clk_1hz <= n(26);
    end process;   
end behavioural;
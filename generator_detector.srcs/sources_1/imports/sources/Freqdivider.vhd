library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Freqdivider is
    port(
        clk100 : in std_logic;
        clk1   : out std_logic
    );
end Freqdivider;

architecture Behavioral of Freqdivider is
    signal n : std_logic_vector(26 downto 0) := (others => '0');
begin
    process(clk100)
    begin
        if rising_edge(clk100) then
            n <= n + 1;
        end if;
        clk1 <= n(26);
    end process;
end Behavioral;

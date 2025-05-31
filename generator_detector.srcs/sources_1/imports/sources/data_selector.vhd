library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_selector is
port(
    M0: in std_logic;
    data: out std_logic_vector(15 downto 0)
);
end entity data_selector;

-- simply describes a 2:1 mux with a bit width of 16 bits
-- it has the two data segments hardcoded

architecture behavioural of data_selector is
constant d1: std_logic_vector(15 downto 0) := "0001001000110100";
constant d2: std_logic_vector(15 downto 0) := "0100001100100001";

begin

process(M0)
begin

    if M0 = '0' then
        data <= d1;
    elsif M0 = '1' then
        data <= d2;
    end if;

end process;

end architecture behavioural;
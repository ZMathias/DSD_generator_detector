library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_mux is
Port(
    CLK: in std_logic;
    d_in: in std_logic;
    Qnext: in std_logic;
    out_en: in std_logic;
    Di: out std_logic
);
end entity data_mux;

architecture behavioural of data_mux is
begin

process(CLK, out_en, d_in, Qnext)
begin
    if rising_edge(CLK) then
        if out_en = '0' then
            Di <= d_in;
        elsif out_en = '1' then
            Di <= Qnext;
        end if;
    end if;
end process;

end architecture behavioural;
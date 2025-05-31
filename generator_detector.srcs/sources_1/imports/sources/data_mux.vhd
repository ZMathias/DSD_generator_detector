library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_mux is
Port(
    CLK: in std_logic;
    RST: in std_logic;
    d_in: in std_logic;
    Qnext: in std_logic;
    out_en: in std_logic;
    Di: out std_logic
);
end entity data_mux;

-- describes a simple mux that either wires the flip flop for shifting or for populating it with data
architecture behavioural of data_mux is
begin

process(CLK, out_en, d_in, Qnext, RST)
begin
    if RST = '1' then
        Di <= '1';
    -- this needs to be clocked because it directly drives a bit of std_logic_vector inter_data, the whole data register
    elsif rising_edge(CLK) then
        if out_en = '0' then
            Di <= d_in;
        elsif out_en = '1' then
            Di <= Qnext;
        end if;
    end if;
end process;

end architecture behavioural;
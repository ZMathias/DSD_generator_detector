library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity FivebitCounter is
    port(reset, clk : in std_logic; 
     -- Header (phase) end, message  (phase) end, checksum (phase) end flags
        he, me, ce : out std_logic); 
end FivebitCounter;

architecture Behavioral of FivebitCounter is
-- Storing internal count-state
signal Q : std_logic_vector(4 downto 0);
begin




    process(clk, reset)
        -- Variable for next state
        variable q_next : unsigned(4 downto 0);
    begin
        if reset = '1' then
            Q <= "00000";
        elsif clk'event and clk = '1' then
            q_next := unsigned(Q) + 1;
            
            -- Assign value to the internal state
            Q <= std_logic_vector(q_next);
        end if;
    end process;    

he <= '1' when Q = "00110" else '0';
me <= '1' when Q = "10110" else '0';
ce <= '1' when Q = "11010" else '0';

end Behavioral;

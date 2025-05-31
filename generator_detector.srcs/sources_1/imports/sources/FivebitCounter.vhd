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
            -- If 6 cycles passed the header phase end is signaled
            if q_next = 6 then
                he <= '1';
                me <= '0';
                ce <= '0';
             -- If 22 cycles passed the message phase end is signaled
            elsif q_next = 22 then
                he <= '0';
                me <= '1';
                ce <= '0';
            -- If 26 cycles passed the checksum phase end is signaled
            elsif q_next = 26 then
                he <= '0';
                me <= '0';
                ce <= '1';
            -- If not in any of these 
            else
                he <= '0';
                me <= '0';
                ce <= '0';
            end if;
            -- Assign value to the internal state
            Q <= std_logic_vector(q_next);
        end if;
    end process;    


end Behavioral;

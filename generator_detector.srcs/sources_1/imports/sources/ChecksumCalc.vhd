library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ChecksumCalc is
    port(data : in std_logic_vector(15 downto 0); -- Incoming data 
        chk : out std_logic_vector(3 downto 0)); -- The cchecksum calculated from the incoming data
end ChecksumCalc;

architecture Behavioral of ChecksumCalc is
begin
    -- Calculating first second third and fourth bit of checksum
    chk(0) <= data(0) xor data(1) xor data(2) xor data(3); 
    chk(1) <= data(4) xor data(5) xor data(6) xor data(7);
    chk(2) <= data(8) xor data(9) xor data(10) xor data(11);
    chk(3) <= data(12) xor data(13) xor data(14) xor data(15);
    
end Behavioral;

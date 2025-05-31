library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ChecksumComp is
    port( A, B : in std_logic_vector(3 downto 0);
        Y : out std_logic);
end ChecksumComp;

architecture Behavioral of ChecksumComp is
signal interm : std_logic_vector(3 downto 0); 
begin
    -- A xnor B = '1' only if the two values are the same
    interm(0) <= A(0) xnor B(0);
    interm(1) <= A(1) xnor B(1);
    interm(2) <= A(2) xnor B(2);
    interm(3) <= A(3) xnor B(3);
    -- Y is 1 only if the two compared values were the same
    Y <= interm(0) and interm(1) and interm (2) and interm(3);
end Behavioral;

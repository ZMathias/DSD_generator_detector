library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HeaderComp is
    port( A, B : in std_logic_vector(5 downto 0);
        Y : out std_logic);
end HeaderComp;

architecture Behavioral of HeaderComp is
signal interm : std_logic_vector(5 downto 0); 
begin
-- A xnor B = '1' only if the two values are the same
    interm(0) <= A(0) xnor B(0);
    interm(1) <= A(1) xnor B(1);
    interm(2) <= A(2) xnor B(2);
    interm(3) <= A(3) xnor B(3);
    interm(4) <= A(4) xnor B(4);
    interm(5) <= A(5) xnor B(5);
    -- Y is 1 only if the two compared values were the same
    Y <= interm(0) and interm(1) and interm (2) and interm(3) and interm(4) and interm(5);
end Behavioral;

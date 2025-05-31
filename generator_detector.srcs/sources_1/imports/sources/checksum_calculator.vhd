library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity checksum_calculator is
port(
    DATA: in std_logic_vector(15 downto 0);
    checksum: out std_logic_vector(3 downto 0)
);
end entity checksum_calculator;

architecture behavioural of checksum_calculator is
begin
    checksum(3) <= DATA(15) xor DATA(14) xor DATA(13) xor DATA(12);
    checksum(2) <= DATA(11) xor DATA(10) xor DATA(9) xor DATA(8);
    checksum(1) <= DATA(7) xor DATA(6) xor DATA(5) xor DATA(4);
    checksum(0) <= DATA(3) xor DATA(2) xor DATA(1) xor DATA(0);
end architecture behavioural;

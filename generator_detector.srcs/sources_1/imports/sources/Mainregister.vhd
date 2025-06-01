library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity definition for the main shift register
entity Mainregister is
    -- Generic: Defines the total length of the shift register (default 26 bits)
    generic (N: INTEGER := 26);
    port(
        data    : in std_logic; -- Input: Serial data bit coming in
        clk     : in std_logic; -- Input: Clock signal
        reset   : in std_logic; -- Input: Reset signal

        -- Output: Buffer for the first 6 bits 
        headerb : out std_logic_vector(5 downto 0);
        -- Output: Buffer for the first 4 bits 
        checksumb : out std_logic_vector(3 downto 0);
        -- Output: Buffer for bits 5 to 20 
        datab   : out std_logic_vector(0 to 15)
    );
end Mainregister;

-- Structural architecture, built from D Flip-Flop components
architecture Structural of Mainregister is

    -- Internal signal array holding the shift register's state
    signal intermed : std_logic_vector(1 to N);

    -- Declaration of the D-type Flip-Flop component
    component DFF
        port(
            d     : in std_logic; -- Data input
            reset : in std_logic; -- Reset input
            clk   : in std_logic; -- Clock input
            q     : out std_logic -- Data output
        );
    end component;

begin

    -- Instantiation of the first DFF, connected to the 'data'
    first_dff : DFF port map(
        d     => data,
        reset => reset,
        clk   => clk,
        q     => intermed(1)
    );

    -- Generates and connects the middle DFFs in a chain 
    middle_dffs : for i in 1 to N - 2 generate
        dff_i : DFF port map(
            d     => intermed(i),
            reset => reset,
            clk   => clk,
            q     => intermed(i+1)
        );
    end generate middle_dffs;

    -- Instantiation of the last DFF in the chain
    last_dff : DFF port map(
        d     => intermed(N-1),
        reset => reset,
        clk   => clk,
        q     => intermed(N)
    );


    -- Assigns the first 4 bits  to checksumb
    checksumb <= intermed(1 to 4);
    -- Assigns the first 6 bits  to headerb
    headerb <= intermed(1 to 6);
    -- Assigns bits 5 through 20  to datab
    datab <= intermed(5 to 20);

end Structural;
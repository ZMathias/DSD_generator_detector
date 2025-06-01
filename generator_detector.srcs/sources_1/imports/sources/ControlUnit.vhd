library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration for the ControlUnit
entity ControlUnit is
    port( 
    -- serial data input of the detector
    data : in std_logic;
    -- end phase signals from five bit counter header, message, checksum phase end
     me: in std_logic; ce: in std_logic; he: in std_logic;
     -- header correct and checksum correct signals from the comparators
     hc, cc: in std_logic;  
     
     clk, reset : in std_logic;
     -- iinternalreset = generated in standby to assure a known state
     -- hf, mf, cf generated flags
        internalreset, hf, mf, cf: out std_logic);
end ControlUnit;

architecture Structural of ControlUnit is

-- Delay flip-flop
component DFF is port(
    d, reset, clk : in std_logic;
    q : out std_logic
    );
end component DFF;

-- Signals for storing internal state and interfacing D flip-flops
signal next_state_d0 : std_logic;
signal next_state_d1 : std_logic;

signal state         : std_logic_vector(1 downto 0); -- Current FSM state

-- Cf latch for handling specified cf behaviour of memorization and clear on reset
signal cf_latch      : std_logic;

begin

-- D-Flip-Flops for storing the current state
DFF_0 : DFF
    port map(
        d => next_state_d0,
        clk => clk,
        reset => reset,
        q => state(0)
    );
    
DFF_1 : DFF
    port map(
        d => next_state_d1,
        clk => clk,
        reset => reset,
        q => state(1)
    );


-- Combinational process defining FSM next state logic
process(data, me , he, ce, hc, cc, state)
begin
    -- Implementing state transition based on the diagram
    -- State encodings: 
    -- 00 - Standby
    -- 01 - Receiving Header
    -- 11 - Receiving Message
    -- 10 - Receiving Checksum
    if state = "00" then
        next_state_d1 <= '0';
        next_state_d0 <= not data;
    elsif state = "01" then
        next_state_d1 <= hc and he;
        if hc = he then
            next_state_d0 <= '1';
        elsif hc = '1' then
            next_state_d0 <= '1';
        else
            next_state_d0 <= '0';
        end if;
    elsif state = "10" then
        next_state_d1 <= not ce;
        next_state_d0 <= '0';
    else -- state = "11"
        next_state_d1 <= '1';
        next_state_d0 <= not me;
    
    end if;
end process;

-- Output assignments
-- Internalreset in standby
internalreset <= '1' when state = "00" else '0';

--
hf <= ((not state(0) and state(1)) or       -- state = 00
        (not (he and not hc) and (state(0) and not state(1))) or -- if header was correct and state = 10
        (state(0) and state(1)) or         -- state = 11
        ((not data) and not state(0) and not state(1))); -- state = 00 but data = 1 so transmission started   

-- Message flag
mf <= '1' when state = "10" else
      '1' when state = "11" else
      '1' when he = '1' else '0';
      
cf <= ((not state(0) and not state(1)) or  (ce and cc)) -- if in state = 00 or currently calculated checksum is correct
        and cf_latch; -- AND latch is high


-- Process for cf_latch logic, sensitive to falling clock edge and reset
process(clk, reset)
begin
    if reset = '1' then
        cf_latch <= '0'; -- Asynchronous, active-high reset
    elsif clk'event and clk = '0' then -- Falling edge triggered
        if (ce = '1' and cc = '1') then
            cf_latch <= '1'; -- Set condition
        elsif (not state(1) and state(0)) = '1' then -- state = "10"
            cf_latch <= '0'; -- Reset condition
        end if;
    end if;
end process;

end Structural;
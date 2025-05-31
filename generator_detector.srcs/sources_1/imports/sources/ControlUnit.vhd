library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ControlUnit is
    port( data, me, ce, hc, he, clk, cc, reset : in std_logic;
        internalreset, hf, mf, cf: out std_logic;
         stateout : out std_logic_vector(1 downto 0));
end ControlUnit;

architecture Structural of ControlUnit is

component DFF is port(
    d, reset, clk : in std_logic;
    q : out std_logic
    );
end component DFF;

signal next_state_d0 : std_logic;
signal next_state_d1 : std_logic;

signal state : std_logic_vector(1 downto 0);

signal cf_latch : std_logic;


begin

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



process(data, me , he, ce, hc, cc, state)

begin
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
    else
        next_state_d1 <= '1';
        next_state_d0 <= not me;
    
    end if;
end process;

internalreset <= '1' when state = "00" else '0';
hf <= ((not state(0) and state(1)) or (not (he and not hc) and (state(0) and not state(1))) or (state(0) and state(1)) or ((not data) and not state(0) and not state(1)));
mf <= '1' when state = "10" else
      '1' when state = "11" else '0';
      
cf <= ((not state(0) and not state(1)) or (ce and cc)) and cf_latch;

stateout <= state;


process(clk, reset)
begin
    if reset = '1' then
        cf_latch <= '0'; -- Asynchronous, active-high reset
    elsif clk'event and clk = '0' then -- Or falling_edge(clk) depending on your design
        if (ce = '1' and cc = '1') then
            cf_latch <= '1'; -- Set on clock edge if conditions met
        elsif (not state(1) and state(0)) = '1' then
            cf_latch <= '0';
        end if;
    end if;
end process;

end Structural;

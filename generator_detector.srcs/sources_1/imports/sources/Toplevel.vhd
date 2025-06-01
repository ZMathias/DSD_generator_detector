library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Toplevel is
    port(
        reset, clk, run : in std_logic;--, sel : in std_logic;
        mode : in std_logic_vector(1 downto 0);
        clk_sw: in std_logic;
        hf, mf, cf, clkout: out std_logic;
        
        seg  : out std_logic_vector(6 downto 0);  -- Segments A-G (Active LOW)
        an   : out std_logic_vector(3 downto 0)
    );
end Toplevel;



architecture Strcutural of Toplevel is

component Generator is port(
    RUN: in std_logic; -- needed to run the transmission
    RST: in std_logic; -- reset
    MODE: in std_logic_vector(1 downto 0); -- mode setting to test the system with mock data
    HF, CF: in std_logic; -- header flag and checksum flag that is received from the detector
    CLK_fast: in std_logic; -- 100mhz clock from the FPGA
    CLK_out: out std_logic;
    S_OUT: out std_logic; -- serial out
    TC: out std_logic -- terminal count
    --sel: in std_logic -- dbg input for window selection
    
    -- outputs for display
    --anodes: out std_logic_vector(3 downto 0);
    --cathodes: out std_logic_vector(6 downto 0)
);
end component;

component Detector is
    port(
        data, reset, clk, internalclk : in std_logic;
        hf, mf, cf, clkout: out std_logic;
        seg  : out std_logic_vector(6 downto 0);  -- Segments A-G (Active LOW)
        an   : out std_logic_vector(3 downto 0)   -- anode controller
    );
end component;

signal internalclk : std_logic;
signal datainternal : std_logic;
signal cfinternal : std_logic;
signal hfinternal : std_logic;
signal tcinternal : std_logic; --TC not used
signal gated_clk: std_logic := '1';

begin

gated_clk <= internalclk and clk_sw; -- this gates the clock for debugging, this is used to pause the transmission to check states and flags

generator_0 : Generator port map(
    CLK_fast => clk,
    CLK_out => internalclk,
    RUN => run,
    RST => reset,
    MODE => mode,
    HF => hfinternal,
    CF => cfinternal,
    S_OUT => datainternal,
    TC => tcinternal --not used
);


detector_0 : Detector port map(
    data => datainternal,
    hf => hfinternal,
    mf => mf, -- not used
    cf => cfinternal,
    seg => seg,
    an => an,
    clkout => clkout,
    clk => clk,
    internalclk => gated_clk,
    reset => reset
);

cf <= cfinternal;
hf <= hfinternal;

end Strcutural;

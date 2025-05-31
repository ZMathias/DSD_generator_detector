library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Detector is
    port(
        data, reset, clk, internalclk : in std_logic;
        hf, mf, cf, clkout, dataout, lout : out std_logic;
        state : out std_logic_vector(1 downto 0);
        seg  : out std_logic_vector(6 downto 0);  -- Segments A-G (Active LOW)
        an   : out std_logic_vector(3 downto 0)
    );
end Detector;

architecture Structural of Detector is

component ChecksumCalc
    port(data : in std_logic_vector(15 downto 0);
        chk : out std_logic_vector(3 downto 0));
end component;

component ChecksumComp
    port( A, B : in std_logic_vector(3 downto 0);
        Y : out std_logic);
end component;

component HeaderComp
    port( A, B : in std_logic_vector(5 downto 0);
        Y : out std_logic);
end component;

component FivebitCounter
    port(reset, clk : in std_logic;
        he, me, ce : out std_logic);
end component;

component Mainregister is
    generic (N: INTEGER := 26);
    port(data, clk, reset : in std_logic;
        headerb : out std_logic_vector(5 downto 0);
        checksumb : out std_logic_vector(3 downto 0);
        datab : out std_logic_vector(0 to 15));
end component;

component ControlUnit 
    port( data, me, ce, hc, he, clk, cc, reset : in std_logic;
        internalreset, hf, mf, cf, lout : out std_logic;
        stateout : out std_logic_vector(1 downto 0));
end component;

component seven_segment_hex_driver 
     port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0); -- 4-bit hex value per digit
        enable   : in std_logic; -- enable the display 
        seg_out  : out std_logic_vector(6 downto 0);  -- Segments A-G (Active LOW)
        an_out   : out std_logic_vector(3 downto 0)   -- Anodes AN0-AN3 (Active LOW)
    );
end component;

signal internalreset_internal : std_logic;
signal resourcereset : std_logic;


signal hf_internal : std_logic;
signal mf_internal : std_logic;
signal cf_internal : std_logic;

signal headerb_internal : std_logic_vector(5 downto 0);
signal checksumb_internal : std_logic_vector(3 downto 0);
signal datab_internal : std_logic_vector(15 downto 0);
signal data_reversed: std_logic_vector(15 downto 0);

signal calculated_checksum_internal : std_logic_vector(3 downto 0);

signal data_internal : std_logic;
signal me_internal : std_logic;
signal ce_internal : std_logic;
signal hc_internal : std_logic;
signal he_internal : std_logic;
signal cc_internal : std_logic;

signal header_comp_internal : std_logic;

signal header_hardcoded : std_logic_vector(5 downto 0);

signal ssd_enable : std_logic;

FUNCTION bit_reverse(s1:std_logic_vector) return std_logic_vector is
     variable rr : std_logic_vector(s1'high downto s1'low);
  begin
    for ii in s1'high downto s1'low loop
      rr(ii) := s1(s1'high-ii);
    end loop;
    return rr;
  end bit_reverse;

begin
data_internal <= data;
dataout <= data;
header_hardcoded <= "110011";
resourcereset <= reset or internalreset_internal;
hc_internal <= header_comp_internal and he_internal;

data_reversed <= bit_reverse(s1 => datab_internal);

seven_segment_hex_driver_0 : seven_segment_hex_driver port map(
     clk =>   clk, 
     rst =>     reset,
     data_in  => data_reversed,
     seg_out  => seg,
     an_out => an,
     enable => ssd_enable
);

mainregister_0 : Mainregister port map(
    data => data_internal,
    reset => resourcereset,
    clk => internalclk,
    headerb => headerb_internal,
    checksumb => checksumb_internal,
    datab => datab_internal
);

--freqdivider_0 : Freqdivider port map(
--    clk100 => clk,
--    clk1 => internalclk
--);

checksumcalc_0 : ChecksumCalc port map(
    data => datab_internal,
    chk => calculated_checksum_internal
);

checksumcomp_0 : ChecksumComp port map(
    a => checksumb_internal,
    b => calculated_checksum_internal,
    y => cc_internal
);

headercomp_0 : HeaderComp port map(
    a => headerb_internal,
    b => header_hardcoded,
    y => header_comp_internal
);

fivebitcounter_0 : FivebitCounter port map(
    reset => resourcereset,
    clk => internalclk,
    he => he_internal,
    me => me_internal,
    ce => ce_internal
);

controlunit_0 : ControlUnit port map(
    data => data_internal,
    me => me_internal,
    ce => ce_internal,
    hc => hc_internal,
    he => he_internal,
    cc => cc_internal,
    clk => internalclk,
    reset => reset,
    lout => lout,
    internalreset => internalreset_internal,
    hf => hf_internal,
    mf => mf_internal,
    cf => cf_internal,
    stateout => state
);

hf <= hf_internal;
mf <= mf_internal;
cf <= cf_internal;
ssd_enable <= hf_internal and mf_internal and cf_internal; -- only enable if received data is valid
clkout <= internalclk;

end Structural;

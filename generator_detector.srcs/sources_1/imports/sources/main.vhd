library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Generator is
port(
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
end entity Generator;

architecture structural of Generator is

component exec_unit is
    Port(
        run      : in  std_logic;
        t_end    : in  std_logic;
        hf       : in  std_logic;
        cf       : in  std_logic;
        reset    : in  std_logic;
        clk      : in  std_logic;
        CNT_EN   : out std_logic;
        OUT_EN   : out std_logic;
        TC       : out std_logic;
        FC       : out std_logic;
        state_out: out std_logic_vector(1 downto 0)
    );
end component;

component data_seg is
Port(
    CLK: in std_logic;
    MODE: in std_logic_vector(1 downto 0);
    FC: in std_logic;
    OUT_EN: in std_logic;
    DATA: out std_logic_vector(26 downto 0) -- the whole 27 bit data segment
);
end component;

component bit_counter is
port(
    clk, cnt_en: in std_logic;
    T_END: out std_logic
);
end component;

--component seven_segment_hex_driver is
--    port (
--       clk      : in  std_logic;
--        rst      : in  std_logic;
--        data_in  : in  std_logic_vector(15 downto 0); -- 4-bit hex value per digit
--
--        seg_out  : out std_logic_vector(6 downto 0);  -- Segments A-G (Active LOW)
--        an_out   : out std_logic_vector(3 downto 0)   -- Anodes AN0-AN3 (Active LOW)
--    );
--end component;

component freq_div is
    port(
        clk100: in std_logic;
        clk_1hz: out std_logic
    );
end component;

signal CLK_slow: std_logic := '0'; -- ~1 HZ clock

signal dbg_state: std_logic_vector(15 downto 0) := (others => '0');
signal complete_data_seg: std_logic_vector(26 downto 0) := (others => '1');
signal data_window: std_logic_vector(15 downto 0) := (others => '0');

-- EU signals
signal inter_OUT_EN: std_logic := '0';
signal inter_CNT_EN: std_logic := '0';
signal inter_FC: std_logic := '0';

-- bit counter signals
signal inter_T_END: std_logic := '0';

begin

div: freq_div port map(clk100 => CLK_fast, clk_1hz => CLK_slow);
CLK_out <= CLK_slow;
--ssd_driver: seven_segment_hex_driver port map(clk => CLK_fast, rst => '0', data_in => data_window, seg_out => cathodes, an_out => anodes);
data_sel: data_seg port map(CLK => CLK_slow, MODE => MODE, FC => inter_FC, OUT_EN => inter_OUT_EN, DATA => complete_data_seg);
EU: exec_unit port map(run => RUN, t_end => inter_T_END, hf => HF, cf => CF, reset => RST, CLK => CLK_slow, CNT_EN => inter_CNT_EN, OUT_EN => inter_OUT_EN, TC => TC, FC => inter_FC, state_out => dbg_state(1 downto 0));
counter: bit_counter port map(clk => CLK_slow, cnt_en => inter_CNT_EN, T_END => inter_T_END);

serial_out_gating: process(inter_OUT_EN, complete_data_seg)
begin

    if inter_OUT_EN = '0' then
        S_OUT <= '1';
    elsif inter_OUT_EN = '1' then
        S_OUT <= complete_data_seg(26);
    end if;

end process;

end architecture structural;
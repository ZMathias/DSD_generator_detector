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

-- component declarations

component control_unit is
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
    RST: in std_logic;
    MODE: in std_logic_vector(1 downto 0);
    FC: in std_logic;
    OUT_EN: in std_logic;
    S_OUT: out std_logic
);
end component;

component bit_counter is
port(
    clk, cnt_en: in std_logic;
    T_END: out std_logic
);
end component;

component freq_div is
    port(
        clk100: in std_logic;
        clk_1hz: out std_logic
    );
end component;

signal CLK_slow: std_logic := '0'; -- ~1 HZ clock

-- this contains the state of the generator
-- used for debugging and outputting to the SSD of the Basys 3
-- this can be omitted
signal dbg_state: std_logic_vector(15 downto 0) := (others => '0');

-- CU generated signals
signal inter_OUT_EN: std_logic := '0';
signal inter_CNT_EN: std_logic := '0';
signal inter_FC: std_logic := '0';

-- the internal shift out signal from the data segment itself
signal inter_S_OUT: std_logic := '1';

-- bit counter signals
-- signals the end of transmission for the CU
signal inter_T_END: std_logic := '0';

begin

div: freq_div port map(clk100 => CLK_fast, clk_1hz => CLK_slow); -- frequency divider, creates ~1Hz clock
CLK_out <= CLK_slow; -- this clock is passed on to the detector aswell

-- this defines the whole 26 bit data segment including -- 1 + 6 bits for the header (this includes the first bit which is always zero for transmission start)
                                                        -- 16 bits for the data segment
                                                        -- 4 bits for the checksum calculated internally using the data segment
                                                        -- data is loaded and the buffer is shifted internally
-- this also provides the ungated output signal
-- it is not guaranteed that it is always high when not transmitting therefore an additional gating process is defined at the end of this file    
data_sel: data_seg port map(CLK => CLK_slow, RST => RST, MODE => MODE, FC => inter_FC, OUT_EN => inter_OUT_EN, S_OUT => inter_S_OUT);

-- the file was mistakenly named but vivado does not allow renaming
-- the control unit is located in the "exec_unit.vhdl"
CU: control_unit port map(run => RUN, t_end => inter_T_END, hf => HF, cf => CF, reset => RST, CLK => CLK_slow, CNT_EN => inter_CNT_EN, OUT_EN => inter_OUT_EN, TC => TC, FC => inter_FC, state_out => dbg_state(1 downto 0));

-- this is the first resource that the control unit uses
-- the second is the error latch but that is so simple that it is included and abstractad in 
-- the signal generation and state holding part of the control unit
counter: bit_counter port map(clk => CLK_slow, cnt_en => inter_CNT_EN, T_END => inter_T_END);

-- this assures that the output serial pin is always held logic 'HIGH' when no transmission is in progress
-- this is done to ensure transmission reliability and to adhere to the specifications
serial_out_gating: process(inter_OUT_EN, inter_S_OUT)
begin

    if inter_OUT_EN = '0' then
        S_OUT <= '1';
    elsif inter_OUT_EN = '1' then
        S_OUT <= inter_S_OUT;
    end if;

end process;

end architecture structural;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_seg is
Port(
    CLK: in std_logic;
    RST: in std_logic;
    MODE: in std_logic_vector(1 downto 0);
    FC: in std_logic;
    OUT_EN: in std_logic;
    S_OUT: out std_logic
);
end entity data_seg;

architecture structural of data_seg is

-- component declarations

component checksum_calculator is
port(
    DATA: in std_logic_vector(15 downto 0);
    checksum: out std_logic_vector(3 downto 0)
);
end component;

component data_selector is
port(
    M0: in std_logic;
    data: out std_logic_vector(15 downto 0)
);
end component;

component mode_selector is
port(
    CLK: in std_logic;
    RST: in std_logic;
    MD0, MD1, MD2, MD3: in std_logic;
    MODE: in std_logic_vector(1 downto 0);
    Qnext: in std_logic;
    FC: in std_logic;
    OUT_EN: in std_logic;
    Di: out std_logic
);
end component;

component data_mux is
Port(
    CLK: in std_logic;
    RST: in std_logic;
    d_in: in std_logic;
    Qnext: in std_logic;
    out_en: in std_logic;
    Di: out std_logic
);
end component;

signal inter_data: std_logic_vector(26 downto 0) := (others => '1'); -- all is set high initially
signal data_selection: std_logic_vector(15 downto 0) := (others => '0');
signal checksum_vec: std_logic_vector(3 downto 0) := (others => '0');

begin

-- we need to write 7 mode selectors that load the data for the header
-- we then need 16 bits for the data itself
-- lastly, we need a checksum calculator that feeds into the last four bits
-- this whole module will just have the job of populating the data segment
-- and shifting the data if output is enabled through OUT_EN

checksum_calc: checksum_calculator port map(DATA => data_selection, checksum => checksum_vec);
data_sel: data_selector port map(M0 => Mode(0), data => data_selection);

header0: mode_selector port map(RST => RST, CLK => CLK, MD0 => '0', MD1 => '0', MD2 => '0', MD3 => '0', MODE => MODE, Qnext => inter_data(25), FC => FC, OUT_EN => OUT_EN, Di => inter_data(26));
header1: mode_selector port map(RST => RST, CLK => CLK, MD0 => '1', MD1 => '1', MD2 => '0', MD3 => '1', MODE => MODE, Qnext => inter_data(24), FC => FC, OUT_EN => OUT_EN, Di => inter_data(25));
header2: mode_selector port map(RST => RST, CLK => CLK, MD0 => '1', MD1 => '1', MD2 => '1', MD3 => '1', MODE => MODE, Qnext => inter_data(23), FC => FC, OUT_EN => OUT_EN, Di => inter_data(24));
header3: mode_selector port map(RST => RST, CLK => CLK, MD0 => '0', MD1 => '0', MD2 => '0', MD3 => '0', MODE => MODE, Qnext => inter_data(22), FC => FC, OUT_EN => OUT_EN, Di => inter_data(23));
header4: mode_selector port map(RST => RST, CLK => CLK, MD0 => '0', MD1 => '0', MD2 => '1', MD3 => '0', MODE => MODE, Qnext => inter_data(21), FC => FC, OUT_EN => OUT_EN, Di => inter_data(22));
header5: mode_selector port map(RST => RST, CLK => CLK, MD0 => '1', MD1 => '1', MD2 => '0', MD3 => '1', MODE => MODE, Qnext => inter_data(20), FC => FC, OUT_EN => OUT_EN, Di => inter_data(21));
header6: mode_selector port map(RST => RST, CLK => CLK, MD0 => '1', MD1 => '1', MD2 => '1', MD3 => '1', MODE => MODE, Qnext => inter_data(19), FC => FC, OUT_EN => OUT_EN, Di => inter_data(20));

data7: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(15), Qnext => inter_data(18), out_en => OUT_EN, Di => inter_data(19));
data8: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(14), Qnext => inter_data(17), out_en => OUT_EN, Di => inter_data(18));
data9: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(13), Qnext => inter_data(16), out_en => OUT_EN, Di => inter_data(17));
data10: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(12), Qnext => inter_data(15), out_en => OUT_EN, Di => inter_data(16));
data11: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(11), Qnext => inter_data(14), out_en => OUT_EN, Di => inter_data(15));
data12: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(10), Qnext => inter_data(13), out_en => OUT_EN, Di => inter_data(14));
data13: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(9), Qnext => inter_data(12), out_en => OUT_EN, Di => inter_data(13));
data14: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(8), Qnext => inter_data(11), out_en => OUT_EN, Di => inter_data(12));
data15: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(7), Qnext => inter_data(10), out_en => OUT_EN, Di => inter_data(11));
data16: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(6), Qnext => inter_data(9), out_en => OUT_EN, Di => inter_data(10));
data17: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(5), Qnext => inter_data(8), out_en => OUT_EN, Di => inter_data(9));
data18: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(4), Qnext => inter_data(7), out_en => OUT_EN, Di => inter_data(8));
data19: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(3), Qnext => inter_data(6), out_en => OUT_EN, Di => inter_data(7));
data20: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(2), Qnext => inter_data(5), out_en => OUT_EN, Di => inter_data(6));
data21: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(1), Qnext => inter_data(4), out_en => OUT_EN, Di => inter_data(5));
data22: data_mux port map(RST => RST, CLK => CLK, d_in => data_selection(0), Qnext => inter_data(3), out_en => OUT_EN, Di => inter_data(4));

checksum23: mode_selector port map(RST => RST, CLK => CLK, MD0 => checksum_vec(3), MD1 => checksum_vec(3), MD2 => checksum_vec(3), MD3 => '0', MODE => MODE, Qnext => inter_data(2), FC => FC, OUT_EN => OUT_EN, Di => inter_data(3));
checksum24: mode_selector port map(RST => RST, CLK => CLK, MD0 => checksum_vec(2), MD1 => checksum_vec(2), MD2 => checksum_vec(2), MD3 => '0', MODE => MODE, Qnext => inter_data(1), FC => FC, OUT_EN => OUT_EN, Di => inter_data(2));
checksum25: mode_selector port map(RST => RST, CLK => CLK, MD0 => checksum_vec(1), MD1 => checksum_vec(1), MD2 => checksum_vec(1), MD3 => '0', MODE => MODE, Qnext => inter_data(0), FC => FC, OUT_EN => OUT_EN, Di => inter_data(1));
checksum26: mode_selector port map(RST => RST, CLK => CLK, MD0 => checksum_vec(0), MD1 => checksum_vec(0), MD2 => checksum_vec(0), MD3 => '0', MODE => MODE, Qnext => '1', FC => FC, OUT_EN => OUT_EN, Di => inter_data(0));

S_OUT <= inter_data(26); -- assign the output bit
end architecture structural;
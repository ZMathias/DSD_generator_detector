library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration for the seven-segment hexadecimal driver
entity seven_segment_hex_driver is
    port (
        clk     : in  std_logic;                     
        rst     : in  std_logic;                     --Asynchronous reset 
        data_in : in  std_logic_vector(15 downto 0); --16-bit data (4 bits for each of the 4 digits)
        enable  : in std_logic; -- enable the display
        seg_out : out std_logic_vector(6 downto 0);  -- 7-segment display segments 
        an_out  : out std_logic_vector(3 downto 0)   -- Anode signals for the 4 digits 
    );
end entity seven_segment_hex_driver;

architecture Behavioral of seven_segment_hex_driver is

    -- System clock frequency (100 MHz)
    constant CLK_FREQ                 : integer := 100_000_000;
    -- Desired refresh frequency for the display (1 kHz)
    constant REFRESH_FREQ             : integer := 1_000;
    -- Clock cycles needed for one full refresh cycle
    constant REFRESH_CYCLES_PER_DIGIT : integer := CLK_FREQ / REFRESH_FREQ;
    -- Clock cycles allocated for displaying each single digit
    constant MUX_CYCLES_PER_DIGIT     : integer := REFRESH_CYCLES_PER_DIGIT / 4;

    -- Counter for timing the multiplexing between digits
    signal refresh_counter : integer range 0 to MUX_CYCLES_PER_DIGIT - 1 := 0;
    -- Selects the current digit to be displayed (00 to 11)
    signal digit_select    : std_logic_vector(1 downto 0) := "00";

    -- Holds the 4-bit hex value for the currently selected digit
    signal current_digit_hex : std_logic_vector(3 downto 0);
    -- Holds the 7-segment pattern for the current hex value
    signal segment_pattern   : std_logic_vector(6 downto 0);

begin

    -- Process for handling the timing and selection of digits (multiplexing)
    digit_mux_timing_proc : process(clk, rst)
    begin
        if rst = '1' then -- If reset is active
            refresh_counter <= 0;    -- Reset the counter
            digit_select    <= "00"; -- Select the first digit
        elsif rising_edge(clk) then -- On the rising edge of the clock
            if refresh_counter = MUX_CYCLES_PER_DIGIT - 1 then -- If the counter reaches its max value
                refresh_counter <= 0;    -- Reset the counter
                -- Move to the next digit (00 -> 01 -> 10 -> 11 -> 00)
                digit_select <= std_logic_vector(unsigned(digit_select) + 1);
            else
                refresh_counter <= refresh_counter + 1; -- Increment the counter
            end if;
        end if;
    end process digit_mux_timing_proc;

    -- Process for selecting the appropriate 4-bit data based on the current digit
    data_selector_proc : process(digit_select, data_in)
    begin
        case digit_select is
            when "00" => -- Digit 0
                current_digit_hex <= data_in(3 downto 0);
            when "01" => -- Digit 1
                current_digit_hex <= data_in(7 downto 4);
            when "10" => -- Digit 2
                current_digit_hex <= data_in(11 downto 8);
            when "11" => -- Digit 3
                current_digit_hex <= data_in(15 downto 12);
            when others => -- Should not happen
                current_digit_hex <= "1111"; -- Display 'F' or blank
        end case;
    end process data_selector_proc;

    -- Process for converting the 4-bit hex value to a 7-segment pattern (Active LOW)
    hex_decoder_proc : process(current_digit_hex)
    begin
        -- '0' means the segment is ON, '1' means OFF.
        case current_digit_hex is
            when "0000" => segment_pattern <= "1000000"; -- 0
            when "0001" => segment_pattern <= "1111001"; -- 1
            when "0010" => segment_pattern <= "0100100"; -- 2
            when "0011" => segment_pattern <= "0110000"; -- 3
            when "0100" => segment_pattern <= "0011001"; -- 4
            when "0101" => segment_pattern <= "0010010"; -- 5
            when "0110" => segment_pattern <= "0000010"; -- 6
            when "0111" => segment_pattern <= "1111000"; -- 7
            when "1000" => segment_pattern <= "0000000"; -- 8
            when "1001" => segment_pattern <= "0010000"; -- 9
            when "1010" => segment_pattern <= "0001000"; -- A
            when "1011" => segment_pattern <= "0000011"; -- b
            when "1100" => segment_pattern <= "1000110"; -- C
            when "1101" => segment_pattern <= "0100001"; -- d
            when "1110" => segment_pattern <= "0000110"; -- E
            when "1111" => segment_pattern <= "0001110"; -- F
            when others => segment_pattern <= "1111111"; -- Blank/Off
        end case;
    end process hex_decoder_proc;

    -- Process for selecting which anode to activate (Active LOW)
    anode_selector_proc : process(digit_select)
    begin
        if enable = '1' then  
            case digit_select is
                when "00" => an_out <= "1110"; -- Activate AN0 (Digit 0)
                when "01" => an_out <= "1101"; -- Activate AN1 (Digit 1)
                when "10" => an_out <= "1011"; -- Activate AN2 (Digit 2)
                when "11" => an_out <= "0111"; -- Activate AN3 (Digit 3)
                when others => an_out <= "1111"; -- Keep all anodes OFF
            end case;
            else
                an_out <= "1111"; --disable display
        end if;
    end process anode_selector_proc;

    -- Drive the segment outputs with the current pattern
    seg_out <= segment_pattern;

end architecture Behavioral;
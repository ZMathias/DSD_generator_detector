library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity exec_unit is
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
end entity exec_unit;

architecture behavioural of exec_unit is

    constant S_STANDBY              : std_logic_vector(1 downto 0) := "00";
    constant S_TRANSMIT             : std_logic_vector(1 downto 0) := "01";
    constant S_VERIFY               : std_logic_vector(1 downto 0) := "10";
    constant S_TRANSMISSION_COMPLETE: std_logic_vector(1 downto 0) := "11";

    signal current_state: std_logic_vector(1 downto 0) := S_STANDBY;
    signal error_state: std_logic := '0';
    
begin
    
    state_process: process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S_STANDBY;
            error_state <= '0'; -- clear_error_state
        elsif rising_edge(clk) then
            case current_state is
                when S_STANDBY =>                                    
                    if run = '1' then
                        current_state <= S_TRANSMIT;
                    elsif run = '0' then
                        if error_state = '1' then
                            current_state <= S_TRANSMIT;
                        else
                            current_state <= S_STANDBY;
                        end if;
                    end if;

                when S_TRANSMIT =>
                    if hf = '0' then
                        error_state <= '1'; -- set_error_state
                        current_state <= S_STANDBY;
                    elsif t_end = '1' then
                        current_state <= S_VERIFY;
                    else
                        current_state <= S_TRANSMIT;
                    end if;
                
                when S_VERIFY =>
                    if cf = '0' then
                        error_state <= '1'; -- set_error_state
                        current_state <= S_STANDBY; -- rerun, will automatically start if run is still active
                    else
                        current_state <= S_TRANSMISSION_COMPLETE;
                    end if;
                
                when S_TRANSMISSION_COMPLETE =>
                    error_state <= '0'; -- clear_error_state once transmission has completed
                    current_state <= S_STANDBY;
                    
                when others =>
                    current_state <= S_STANDBY;

            end case;
        end if;
    end process state_process;

    outputs_process: process(current_state, error_state)
    begin
        CNT_EN <= '0';
        OUT_EN <= '0';
        TC     <= '0';
        FC     <= error_state;
        
        case current_state is
            when S_STANDBY =>
                CNT_EN <= '0';
                OUT_EN <= '0';
                TC     <= '0';

            when S_TRANSMIT =>
                CNT_EN <= '1';
                OUT_EN <= '1';
                TC     <= '0';

            when S_TRANSMISSION_COMPLETE =>
                CNT_EN <= '0';
                OUT_EN <= '0';
                TC     <= '1';

            when others =>
                CNT_EN <= '0';
                OUT_EN <= '0';
                TC     <= '0';
        end case;
    end process outputs_process;

    state_out <= current_state;

end architecture behavioural;